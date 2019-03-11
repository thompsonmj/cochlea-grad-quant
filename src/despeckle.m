function imgDespeckled = despeckle()  
% DESPECKLE removes/smoothes speckled immunofluorescence images while
% preserving data fidelity.
%
% To use:
% 0.1) In .../tif-orient/sep-ch/sub-bkgd/sep-z/_dat_, store all images to be
% despeckled. These should be separated single images (not z-stacks).
% 0.2) In .../tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/_dat_, store all
% images that do not need despeckled.
% 1) Run this file and select the directory with the files to be
% despeckled.
% This function will process each file, append "_despeckled" to the
% filename, and save it to the location in step 0.2. Writing will add a
% comment to the image noting the threshold used for despeckling.

startDir = pwd;

% Select an image stack.
%[file,path] = uigetfile;

% Select a directory of z stacks
fdir = uigetdir;

% Make struct of files in directory.
files = dir( fullfile(fdir, '*.tif') );
nFiles = length(files);

% Move to the folder where despeckled images are to be saved.
fdirNew = fullfile(fdir,'..','despeckle','_dat_');
cd(fdirNew);

for iFile = 1:nFiles 
    %% Set parameters.
    % Intensity difference ratio to trigger despeckling. Normalized to the
    % difference between the image's max and min intensity. Used to
    % calculate a differense threshold value for neighboring pixels.
    RATIO = 0.3;
    
    % Sampling radius. How far a 'speckled' pixel looks to check what it
    % should be.
    SR = 2;
    
    assert(0 < RATIO && RATIO < 1);
    
    %% Algorithm
    [fdir, fname, fext] = fileparts( ...
        fullfile( files(iFile).folder,files(iFile).name ) );
    % fdir: directory containing file only, no file name
    % fname: file name only, no path or extension
    % fext: file extension only
    
    f = fullfile(fdir,[fname,fext]);
    img = imread(f);
    
    % Initialize a copy to edit.
    imgDespeckle = img; 
    
    fprintf('Now reading: %s\n', [fname,fext]);
    
    % % Load stack.
    % info = imfinfo(file);
    % nSlices = length(info);
    % imgStack = [];
    %
    % tifLink = Tiff([path,file], 'r');
    % for iSlice = 1:nSlices
    %     tifLink.setDirectory(iSlice);
    %     imgStack(:,:,iSlice) = tifLink.read();
    % end
    
    %%%%%%%%%%%%%%%
    % for iSlice = 1:nSlices
    %    img = imread(file, 'Index', iSlice, 'Info', info);
    %    imgStack(:,:,iSlice) = img;
    % end
    %%%%%%%%%%%%%%%
    
    % Original image for preview, normalized, 0 - 1. (for preview only)
    %%%imgGrayScale = mat2gray(img);
    THRESHOLD = RATIO*( max(max(imgDespeckle)) - min(min(imgDespeckle)) );
    
    imgDims = size(img);
    nRows = imgDims(1);
    nCols = imgDims(2);
    
    % Count number of operations.
    counter = 0;
    for iRow = 10:nRows-10
        for iCol = 10:nCols-10
            %%% These should be written better.
            for neighborOrder = 1:2
                if imgDespeckle(iRow,iCol) > ...
                        imgDespeckle(iRow+neighborOrder,iCol) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle,SR);
                    counter = counter + 1;
                    disp(counter)
                end
                if imgDespeckle(iRow,iCol) > ...
                        imgDespeckle(iRow,iCol+neighborOrder) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle,SR);
                    counter = counter + 1;
                    disp(counter)
                end
                if imgDespeckle(iRow,iCol) > ...
                        imgDespeckle(iRow-neighborOrder,iCol) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle,SR);
                    counter = counter + 1;
                    disp(counter)
                end
                if imgDespeckle(iRow,iCol) > ...
                        imgDespeckle(iRow,iCol-neighborOrder) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle,SR);
                    counter = counter + 1;
                    disp(counter)
                end
            end
        end
    end
    
    % Edited image for preview, normalized, 0:1. (for preview only)
    %%% Combine into a stack.
    % imgGrayScale_edit = mat2gray(imgDespeckle);
    
    % Preview edits.
    %%% Combine into a stack.
%     f1 = figure;
%     subplot(1,2,1)
%     imshow(img)
%     title('Original Raw Image')
%     subplot(1,2,2)
%     imshow(imgDespeckle)
%     title('Despeckled Raw Image')
%     f2 = figure;cd
%     subplot(1,2,1)
%     image(imgGrayScale,'CDataMapping','scaled')
%     colorbar
%     pbaspect([1 1 1])
%     title('Original Normalized Heat Map')
%     xlabel('Pixels')
%     ylabel('Pixels')
%     subplot(1,2,2)
%     image(imgGrayScale_edit,'CDataMapping','scaled')
%     pbaspect([1 1 1])
%     colorbar
%     title('Despeckled Normalized Heat Map')
%     xlabel('Pixels')
%     ylabel('Pixels')
    
    % Save the edited image to the despeckled directory at fdirNew.
    c = [ 'Threshold ratio: ', num2str(RATIO), '. ', ...
         'Sampling radius: ', num2str(SR), '.' ];
    appendedfname = [fname,'_despeckled.tif'];
%     imwrite( imgDespeckle,appendedfname,'tif','Comment',s );
    imwrite( imgDespeckle,appendedfname,'tif','Description',c );
end

cd(startDir)

function newInt = sample(R,C,I,SR)
% If a speckle is found, average the points surrounding it.
% Inputs: R,C: row and column number of the current pixel in question.
%         I: image matrix to update
%         SR: sampling radius
% Output: newInt: new intensity value to assign to the pixel.

samples = cat( 1, I(R-SR, C-SR:C+SR)', ...
                  I(R-SR-1:R+SR-1, C-SR), ...
                  I(R+SR, C-SR:C+SR)', ...
                  I(R-SR-1:R+SR-1, C+SR) );
newInt = mean(samples);

end
end