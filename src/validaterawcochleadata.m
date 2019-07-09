function [validTF, report] = validaterawcochleadata( varargin )
%VALIDATERAWCOCHLEADATA Validate data formatting in Excel workbooks of
%cochlea data extracted from images.
%
% Input:
%   > (optional) Directory holding Excel workbooks.
% Output:
%   > validTF: logical true/false indicating validation pass/fail
%   > report: (optional) struct indicating types and sources of validation
%   problems.

nargin = numel(varargin);
switch nargin
    case 0
        fdir = uigetdir(pwd,'Select directory with data to validate.');
    case 1
        fdir = varargin{1};
end

books = dir(fullfile(fdir,'*.xlsx'));
nBooks = length(books); 

nameErrCount = 0;
sizeErrCount = 0;
xPsnErrCount = 0;
nameErrors = {};
sizeErrors = {};
xPsnErrors = {};

for iBook = 1:nBooks
    [fdir, fname, fext] = fileparts( ...
        fullfile( books(iBook).folder, books(iBook).name ) );
    bookLocNameExt = fullfile(fdir,[fname,fext]);
    
    [~, sheets] = xlsfinfo(bookLocNameExt);
    
    validSheetNamesTF = checkifvalidtargets( sheets );
    if validSheetNamesTF
        % Do nothing.
    else
        nameErrCount = nameErrCount + 1;
        nameErrors{nameErrCount} = bookLocNameExt;
    end
    
    nSheets = numel(sheets);
    sheetsRaw = cell(nSheets,1);
    sheetsNum = cell(nSheets,1);
    for iSheet = 1:nSheets
        [num,~,raw] = xlsread(bookLocNameExt, sheets{iSheet});
        sheetsRaw{iSheet} = raw;
        sheetsNum{iSheet} = num;
    end
    if numel(unique(cellfun('size',sheetsRaw,1))) == 1
        % Do nothing.
    else
        sizeErrCount = sizeErrCount + 1;
        sizeErrors{sizeErrCount} = bookLocNameExt;
    end
    L = sheetsNum{1}(end,1);
    for iSheet = 1:nSheets
        if sheetsNum{iSheet}(end,1) == L
            % Do nothing.
        else
            xPsnErrCount = xPsnErrCount + 1;
            xPsnErrors{xPsnErrCount} = bookLocNameExt;
        end
    end
end    

errCount = nameErrCount + sizeErrCount + xPsnErrCount;
if errCount == 0
    validTF = true;
    report = 'All good, mate';
else
    validTF = false;
    report.sizeErrors = sizeErrors;
    report.xPsnErrors = xPsnErrors;
    report.nameErrors = nameErrors;
end

end