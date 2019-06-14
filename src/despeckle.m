function imgDespeckled = despeckle()  
% DESPECKLE removes/smoothes speckled immunofluorescence images while
% preserving data fidelity.
%
% To use:
% Setup
%   Store all images to be despeckled in a directory that navigates to
%   ../despeckle/_dat_ to store the despeckled versions.
% Execute
%   Run this file on that directory.
% This function will process each file, append "_despeckled" to the
% filename, and save it to the location in step 0.2. Writing will add a
% comment to the image noting the threshold used for despeckling.

% Select an image stack.
%[file,path] = uigetfile;

startDir = pwd;

% Select a directory of z stacks
fdir = uigetdir;
cd(fdir)
% fdir = 'F:\projects\cochlea\data\img\sw\wt\E12.5\30_SW33-1S\tif-orient\mip\sep-ch\to-despeckle';

% Make struct of files in directory.
files = dir( fullfile(fdir, '*.tif') );
nFiles = length(files);

% Move to the folder where despeckled images are to be saved.
% fdirNew = fullfile(fdir,'..','despeckle','_dat_');
% cd(fdirNew);

for iFile = 1:nFiles 
    %% Load file
    [fdir, fname, fext] = fileparts( ...
        fullfile( files(iFile).folder,files(iFile).name ) );
    % fdir: directory containing file only, no file name
    % fname: file name only, no path or extension
    % fext: file extension only
    
    f = fullfile(fdir,[fname,fext]);
    img = imread(f);
    
    % Initialize a copy to edit.
    imgEdit = img; 
    
    fprintf('Now reading: %s\n', [fname,fext]);
    
    %% Setup
    % Intensity difference ratio to trigger despeckling. Normalized to the
    % difference between the image's max and min intensity. Used to
    % calculate a differense threshold value for neighboring pixels.
    RATIO = 0.2;
    
    % Sampling radius. How far a 'speckled' pixel looks to check what it
    % should be.
    SR = 1;
    
    nghbrOrder = 1; %%% Unused for now
    
    maxPasses = 1000;
    %% Algorithm
    assert(0 < RATIO && RATIO < 1);    
    
    THRESH = RATIO*( max(max(imgEdit)) - min(min(imgEdit)) );
    
    imgDims = size(img);
    nRows = imgDims(1);
    nCols = imgDims(2);
    
    counter = 0;
    nghbrRowIdcs = [ 1;  0; -1; 1; -1; 1; 0; -1 ];
    nghbrColIdcs = [-1; -1; -1; 0;  0; 1; 1;  1 ];
    
    newChangeTF = true;
    iPass = 0;
    nPxls = numel(imgEdit);
    s = size(imgEdit);

    pxlTracker = [];
    while newChangeTF && iPass < maxPasses
        iPass = iPass + 1;
        disp(['Pass ',num2str(iPass)])
        newChangeTF = false;
        passEditCount = 0;
        randIdcs = randperm(nPxls);
        [r,c] = ind2sub(s,randIdcs);
        
        for iPxl = 1:nPxls
            overThreshTF = false(8,1);
            if r(iPxl) > 2 && r(iPxl) < s(1) - 2 ...
                    && c(iPxl) > 2 && c(iPxl) < s(2) - 2
                % If not directly on image edge.
                for iNghbr = 1:8
                    if imgEdit( randIdcs(iPxl) ) > ...
                            imgEdit( r(iPxl) + nghbrRowIdcs(iNghbr), ...
                            c(iPxl) + nghbrColIdcs(iNghbr) ) + THRESH
                        overThreshTF(iNghbr) = true;
                    end
                end
            else
                % Too close to the edge.
                continue
            end

            % Sample neighbors.
            idcs = find(overThreshTF);
            if numel(idcs) > 3
                imgEdit(r(iPxl),c(iPxl)) = ...
                    sample( r(iPxl), c(iPxl), imgEdit, idcs );
                counter = counter + 1;
                newChangeTF = true;
                passEditCount = passEditCount+1;
                pxlTracker = [pxlTracker; randIdcs(iPxl)];
            end
        end
        disp(['Edits this pass: ',num2str(passEditCount)])
    end
    disp([num2str(counter), ' changes.'])
    
    % Flag pixels that have been edited to check.
    imgTrack = img;
    imgTrack(pxlTracker) = 65536;
    
    % Save the edited image to the despeckled directory at fdirNew.
    c = [ 'Threshold ratio: ', num2str(RATIO), '. ', ...
         'Sampling radius: ', num2str(SR), '.' ];
    appendedfname = [fname,'_despeckled_',num2str(RATIO),'.tif'];
    appendedfname2 = [fname,'_tracking_',num2str(RATIO),'.tif'];
    % Save new despeckled image.
    imwrite( imgEdit,appendedfname,'tif','Description',c );
    % Save image illustrating the pixels that have been edited.
    imwrite( imgTrack,appendedfname2,'tif','Description',c );

end

cd(startDir)

function newInt = sample(R,C,I,idx)
% If a speckle is found, average the points surrounding it.
% Inputs: R,C: row and column number of the current pixel in question.
%         I: image matrix to update
%         SR: sampling radius
% Output: newInt: new intensity value to assign to the pixel.

% Sample neighbors above, below, to the left, and to the right of the
% current pixel.

rows = [ 1;  0; -1; 1; -1; 1; 0; -1 ];
cols = [-1; -1; -1; 0;  0; 1; 1;  1 ];

nSamples = numel(idx);
samples = zeros(nSamples + 1,1);

for iSample = 1:nSamples
    samples(iSample) = I( R + rows(idx(iSample)), C + cols(idx(iSample)) );
end

samples(end) = I(R,C)/2;

newInt = mean(samples);

end
end