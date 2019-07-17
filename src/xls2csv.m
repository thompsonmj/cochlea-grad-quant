function out = xls2csv(f)
% XLS2CSV writes all sheets of a Microsoft Excel workbook to a new *.csv file, appending the sheet
% names to the end of the filenames.
%
% Input:
%   > f: Path to the Excel file. 
%       E.g. 'Book1.xlsx'
% Output(s):
%   > out: Cell array of character arrays of file names for newly written *.csv files.
% Other behavior:
%   Writes *.csv files for every sheet in an Excel workbook to the workbook's directory.
%       E.g. 'Book1_Sheet1.csv'

[status,sheetNames,~] = xlsfinfo(f);
%assert(isequal(status,'Microsoft Excel Spreadsheet'), ...
%    'Invalid file. Please use a Microsoft Excel .xls or .xlsx file.')
nSheets = size(sheetNames,2);

[fdir, fname, ~] = fileparts( fullfile( f ) );

if isequal(fdir,'')
    fdir = pwd;
end

out = cell(nSheets,1);
for iSheet = 1:nSheets
    [~,~,raw] = xlsread(f,sheetNames{iSheet});
    csvfName = [ fname,'_',sheetNames{iSheet},'.csv' ];
    cell2csv(csvfName, raw)
    
    out{iSheet} = fullfile(fdir,csvfName);
end

end