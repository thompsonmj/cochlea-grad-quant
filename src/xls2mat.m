function out = xls2mat( varargin )
%XLS2MAT converts manually created Excel sheets to a .mat file.
%
% Inputs:
%   > Directory holding quantified data profiles in .xlsx.
% Outputs:
%   > Location of new .mat file.
% Side effects:
%   > Saves data from Excel books to a .mat file.
%   Struct saved includes fields 'xPsn' and 'data' under
%   RawDat.<Section-ID>.<Target-Name>.
%   'xPsn' validated to be in microns.
%   'data' validated to be 16 bit

RawDat = struct;

nargin = numel(varargin);
switch nargin
    case 0
        fdir = uigetdir(pwd,'Select directory with data to validate.');
    case 1
        fdir = varargin{1};
end
books = dir(fullfile(fdir,'*.xlsx'));
nBooks = length(books); 

[validTF, report] = validaterawcochleadata( fdir );
assert(validTF,report)



for iBook = 1:nBooks
    [fdir, fname, fext] = fileparts( ...
        fullfile( books(iBook).folder, books(iBook).name ) );
    bookLocNameExt = fullfile(fdir,[fname,fext]);
    
    [~,sheetNames,~] = xlsfinfo(bookLocNameExt);
    
    nSheets = numel(sheetNames);
    
    % Read section ID from Excel filename. E.g. 'B1' from 'B1.xlsx'
    expression = '^\w+(?=.)';
    str = books(iBook).name;
    [startIdx,endIdx] = regexp(str,expression);
    secID = str(startIdx:endIdx);
    % Copy data into RawDat struct. Convert to 16 bit if neccessary.
    for iSheet = 1:nSheets
        [num,~,~] = xlsread(bookLocNameExt, sheetNames{iSheet});
        RawDat.(secID).(sheetNames{iSheet}).xPsn = num(:,1);
        rawProfile = num(:,2);
        [prof16bit,~] = scaleto16bit( rawProfile );
        RawDat.(secID).(sheetNames{iSheet}).data = prof16bit;
    end
end
startDir = pwd;
cd(fdir)
save('RawDat.mat','RawDat')
cd(startDir)

out = fullfile(fdir,'RawDat.mat');

end