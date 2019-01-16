function imgDespeckled = despeckle()  

% DESPECKLE removes/smoothes speckled immunofluorescence images while
% preserving data fidelity.

% Note start directory.
startDir = pwd;

% Select an image stack.
%[file,path] = uigetfile;

% Select a directory of z stacks
path = uigetdir

% make struct of files in directory
files = dir(fullfile(pawithth, '*.tif')); 
for k = 1:length(files) %loop through all tif files in the user selected directory
    baseFileName = files(k).name % base file name
    fullFileName = fullfile(path, baseFileName); %full name of file
    fprintf(1, 'Now reading %s\n', fullFileName); %tells you which file its despeckling currently
    % Move to data directory.
    cd([path]);
    
    % Set a threshold pixel intensity difference to identify a 'speckle'.
    % prompt = ['Specify a threshold ratio for speckle detection (0 to 1 allowed, ~0.3 recommended). ' ...
    %     'The ratio is the percentage difference between the image''s dimmest and brightest pixels. ' ...
    %     'This is used to calculate a difference threshold value for neighboring pixels.'];
    RATIO = 0.3;%input(prompt);
    assert(0 < RATIO && RATIO < 1);
    
    
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
    img = imread(baseFileName);
    % Initialize a copy to edit.
    imgDespeckle = img;
    
    
    % Original image for preview, normalized, 0 - 1. (for preview only)
    imgGrayScale = mat2gray(img);
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
                if imgDespeckle(iRow,iCol) > imgDespeckle(iRow+neighborOrder,iCol) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle);
                    counter = counter + 1;
                    disp(counter)
                end
                if imgDespeckle(iRow,iCol) > imgDespeckle(iRow,iCol+neighborOrder) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle);
                    counter = counter + 1;
                    disp(counter)
                end
                if imgDespeckle(iRow,iCol) > imgDespeckle(iRow-neighborOrder,iCol) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle);
                    counter = counter + 1;
                    disp(counter)
                end
                if imgDespeckle(iRow,iCol) > imgDespeckle(iRow,iCol-neighborOrder) + THRESHOLD
                    imgDespeckle(iRow,iCol) = sample(iRow,iCol,imgDespeckle);
                    counter = counter + 1;
                    disp(counter)
                end
            end
        end
    end
    
    % Edited image for preview, normalized, 0:1. (for preview only)
    %%% Combine into a stack.
    imgGrayScale_edit = mat2gray(imgDespeckle);
    
    % Preview edits.
    %%% Combine into a stack.
    f1 = figure;
    subplot(1,2,1)
    imshow(img)
    title('Original Raw Image')
    subplot(1,2,2)
    imshow(imgDespeckle)
    title('Despeckled Raw Image')
    f2 = figure;
    subplot(1,2,1)
    image(imgGrayScale,'CDataMapping','scaled')
    colorbar
    pbaspect([1 1 1])
    title('Original Normalized Heat Map')
    xlabel('Pixels')
    ylabel('Pixels')
    subplot(1,2,2)
    image(imgGrayScale_edit,'CDataMapping','scaled')
    pbaspect([1 1 1])
    colorbar
    title('Despeckled Normalized Heat Map')
    xlabel('Pixels')
    ylabel('Pixels')
    
    % cd ../despeckle
    % Move to despeckled folder.
    
    % Save the edited image.
    imwrite(imgDespeckle,[baseFileName,'_deSpeckled.tif'],'tif')
    
    cd(startDir)
end
% If a speckle is found, average the points surrounding it.
function newValue = sample(R,C,I)
% Inputs: R,C: row and column number of the current pixel in question.
%         I: image matrix to update
% Output: newValue: new intensity value to assign to the pixel.

SAMPLE_RADIUS = 2;

samples = cat( 1, I(R-SAMPLE_RADIUS,                     C-SAMPLE_RADIUS:C+SAMPLE_RADIUS)', ...
                  I(R-SAMPLE_RADIUS-1:R+SAMPLE_RADIUS-1, C-SAMPLE_RADIUS       ), ...
                  I(R+SAMPLE_RADIUS,                     C-SAMPLE_RADIUS:C+SAMPLE_RADIUS)', ...
                  I(R-SAMPLE_RADIUS-1:R+SAMPLE_RADIUS-1, C+SAMPLE_RADIUS) );
meanSamples = mean(samples);
newValue = meanSamples;

end
end