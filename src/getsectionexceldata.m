function data = getsectionexceldata( sectionExcelFile )
%GETSECTIONEXCELDATA converts manually created Excel sheets to a .mat file.
%
% Inputs:
%   > File location and name of *.xlsx data file for a single section.
% Outputs:
%   > struct of profile data and profile length in microns.

data = struct( 'psmad',         [], ...
                'sox2',         [], ...
                'jag1',         [], ...
                'bmp4_mrna',    [], ...
                'topro3',       [], ...
                'length',       [] );
%%
% nargin = numel(varargin);
% switch nargin
%     case 0
%         fdir = uigetdir(pwd,'Select directory with data to validate.');
%     case 1
%         fdir = varargin{1};
% end
% 
% startdir = pwd;
% 
% %% Determine cochlea index.
% cd((fullfile(fdir,'..','..','..','..','..')))
% [~,cochleaDir] = fileparts(pwd);
% str = cochleaDir;
% expr = '\d+(?=_)'; % Any numeric digit one or more times preceding underscore.
% [startIdx,endIdx] = regexp(str,expr);
% cochleaIdx = str2num(cochleaDir(startIdx:endIdx));
% %% Determine cochlea age.
% cd('..')
% [~,ageDir] = fileparts(pwd);
% str = ageDir;
% expr = '\d+';
% [startIdx,endIdx] = regexp(str,expr);
% age = str2double(ageDir(startIdx:endIdx));

%%
[~,fname,fext] = fileparts(fullfile(sectionExcelFile));
assert( all(fname(end-3:end) == '_pse'), ...
    'ROI type error.')
assert( all(fext == '.xlsx'), ...
    'Input must be Excel file.')

[~,sheetNames] = xlsfinfo(sectionExcelFile);
validSheetNamesTF = checkifvalidtargets(sheetNames);
assert( validSheetNamesTF, ...
    ['Sheet name error in ',sectionExcelFile,'.'])
nSheets = numel(sheetNames);
for iS = 1:nSheets
    [num,~,~] = xlsread(sectionExcelFile,sheetNames{iS});
    
    data.length = num(end,1);
            
    data.(sheetNames{iS}) = num(:,2);
    
    assert( data.length < numel(data.(sheetNames{iS})), ...
        ['Error in pixel scaling for ',sectionExcelFile,' - ',sheetNames{iS},' channel.'])
end

% for iBook = 1:nBooks
%     idx = idx + 1;
%     [fdir, fname, fext] = fileparts( ...
%         fullfile( books(iBook).folder, books(iBook).name ) );
%     bookLocNameExt = fullfile(fdir,[fname,fext]);
%     
%     [~,sheetNames,~] = xlsfinfo(bookLocNameExt);
%     
%     nSheets = numel(sheetNames);
%     
%     % Read section ID from Excel filename. 
%     % E.g. For a file named 'B1.xlsx': 
%     %   data.section_ab = 'B'
%     %   data.section_idx = 1
%     expression = '^\w{1}(?=\d)'; % Single letter starting at the beginning.
%     str = books(iBook).name;
%     [startIdx,endIdx] = regexp(str,expression);
%     sectionAB = str(startIdx:endIdx);
%     
%     expression = '\d+(?=_)'; % Numeric digits ending before a '.'.
%     str = books(iBook).name;
%     [startIdx,endIdx] = regexp(str,expression);
%     sectionIdx = str2double(str(startIdx:endIdx));
%     
%     % Copy data into RawDat struct. Convert to 16 bit if neccessary.
%     for iSheet = 1:nSheets
%         [num,~,~] = xlsread(bookLocNameExt, sheetNames{iSheet});
%         rawProfile = num(:,2);        
%         %\/\/\/ CONSTRUCTION ZONE \/\/\/
%         data(idx).cochlea_idx = cochleaIdx;
%         data(idx).section_ab = sectionAB;
%         data(idx).section_idx = sectionIdx;
%         data(idx).age = age;
%         data(idx).x = num(:,1);
%         rawProfile = num(:,2);
%         [prof16bit,~] = scaleto16bit(rawProfile);
%         
%         switch lower(sheetNames{iSheet})
%             case 'psmad'
%                 data(idx).psmad = prof16bit;
%             case 'sox2'
%                 data(idx).sox2 = prof16bit;
%             case 'jag1'
%                 data(idx).jag1 = prof16bit;
%             case 'topro3'
%                 data(idx).topro3 = prof16bit;
%         end       
%         %/\/\/\ CONSTRUCTION ZONE /\/\/\
%         
%     end
% end
end