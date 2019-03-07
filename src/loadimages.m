function [rawFileInfo, rawData] = loadimages()
%%% Check read_czi() function in MATLAB-Drive
    % Initialization
    bfCheckJavaPath();

    % User selects directory containing all images to process in a single session.
    startDir = pwd;    
    rawFileDir = uigetdir;
    cd(rawFileDir);
    
    % Create an array of file names with raw data file extensions in the chosen directory.
    extList = {'*.czi','*.ics'};
    iExt = listdlg('PromptString', 'Select the raw image file type:',...
        'SelectionMode', 'Single',...
        'ListString', extList); % Returns numerical index.

    rawFileInfo = dir( fullfile( rawFileDir, extList{iExt} ) );

    nFiles = length(rawFileInfo);
    
    % Initialize cell array to hold imaging data.
    rawData = cell(nFiles,1);
    
    % Import imaging files using Bio-Formats.
    for iFile = 1:nFiles
        rawData{iFile} = bfopen(rawFileInfo(iFile).name);
    end
    
    cd(startDir);
 
end
