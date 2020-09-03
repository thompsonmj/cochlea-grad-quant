function out = xls2structarray(cochleaNo, roiType, varargin )
%XLS2MAT converts manually created Excel sheets to a .mat file.
%
% Inputs:
%   > roiType: 'pm', 'pse', 'lat', 'med'
%   > Directory holding quantified data profiles in .xlsx.
% Outputs:



RawDat = struct;

data = struct( 'age',               [], ...
                'cochlea_idx',      [], ...
                'section_ab',       [], ...
                'section_idx',      [], ...
                ...
                'psmad',            [], ...
                'sox2',             [], ...
                'jag1',             [], ...
                'topro3',           [], ...
                'L',                [], ...
                ...
                'psmad_nuc',        [], ...
                'sox2_nuc',         [], ...
                'topro3_nuc',       [], ...
                'x_nuc',            [], ...
                ...
                'flag',             [], ...
                'pse_roi',          [], ...
                'nuc_roi',          [], ...
                ...
                'img_scale',        [], ... % Keep?
                'pixel_bit_depth',  [], ... % Keep?
                'resolution',       [] );   % Keep?
    
data.psmad.img_file =   [];
data.sox2.img_file =    [];
data.jag1.img_file =    [];
data.topro3.img_file =  [];

data.psmad.despeckled_yn =  [];
data.sox2.despeckled_yn =   [];
data.jag1.despeckled_yn =   [];
data.topro3.despeckled_yn = [];

data.psmad.despeckled_thresh_val =  []; % Keep?
data.sox2.despeckled_thresh_val =   []; % Keep?
data.jag1.despeckled_thresh_val =   []; % Keep?
data.topro3.despeckled_thresh_val = []; % Keep?

nargin = numel(varargin);
switch nargin
    case 0
        fdir = uigetdir(pwd,'Select directory with data to validate.');
    case 1
        fdir = varargin{1};
end

startdir = pwd;

%% Determine cochlea index.
cd((fullfile(fdir,'..','..','..','..','..')))
[~,cochleaDir] = fileparts(pwd);
str = cochleaDir;
expr = '\d+(?=_)'; % Any numeric digit one or more times preceding underscore.
[startIdx,endIdx] = regexp(str,expr);
cochleaIdx = str2num(cochleaDir(startIdx:endIdx));
%% Determine cochlea age.
cd('..')
[~,ageDir] = fileparts(pwd);
str = ageDir;
expr = '\d+';
[startIdx,endIdx] = regexp(str,expr);
age = str2double(ageDir(startIdx:endIdx));

%%
%%%%%%%%%%%%%%%%%%%%%%%%
books = dir(fullfile(fdir,['*',roiType,'.xlsx']));

books.name
nBooks = length(books); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roiValidTF = checkifvalidroitype(roiType);
% [validTF, report] = validaterawcochleadata( roiType, fdir );
% if ~validTF
%     disp(report)
% end
% assert(roiValidTF)
% assert(validTF)

idx = 0;
for iBook = 1:nBooks
    idx = idx + 1;
    [fdir, fname, fext] = fileparts( ...
        fullfile( books(iBook).folder, books(iBook).name ) );
    bookLocNameExt = fullfile(fdir,[fname,fext]);
    
    [~,sheetNames,~] = xlsfinfo(bookLocNameExt);
    
    nSheets = numel(sheetNames);
    
    % Read section ID from Excel filename. 
    % E.g. For a file named 'B1.xlsx': 
    %   data.section_ab = 'B'
    %   data.section_idx = 1
    expression = '^\w{1}(?=\d)'; % Single letter starting at the beginning.
    str = books(iBook).name;
    [startIdx,endIdx] = regexp(str,expression);
    sectionAB = str(startIdx:endIdx);
    
    expression = '\d+(?=_)'; % Numeric digits ending before a '.'.
    str = books(iBook).name;
    [startIdx,endIdx] = regexp(str,expression);
    sectionIdx = str2double(str(startIdx:endIdx));
    
    % Copy data into RawDat struct. Convert to 16 bit if neccessary.
    for iSheet = 1:nSheets
        [num,~,~] = xlsread(bookLocNameExt, sheetNames{iSheet});
        rawProfile = num(:,2);        
        %\/\/\/ CONSTRUCTION ZONE \/\/\/
        data(idx).cochlea_idx = cochleaIdx;
        data(idx).section_ab = sectionAB;
        data(idx).section_idx = sectionIdx;
        data(idx).age = age;
        data(idx).x = num(:,1);
        rawProfile = num(:,2);
        [prof16bit,~] = scaleto16bit(rawProfile);
        
        switch lower(sheetNames{iSheet})
            case 'psmad'
                data(idx).psmad = prof16bit;
            case 'sox2'
                data(idx).sox2 = prof16bit;
            case 'jag1'
                data(idx).jag1 = prof16bit;
            case 'topro3'
                data(idx).topro3 = prof16bit;
        end       
        %/\/\/\ CONSTRUCTION ZONE /\/\/\
        
    end
end

startDir = pwd;
cd(fdir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outfname = ['RawDat_',roiType,'_16-bit_v2.mat'];
save(outfname,'data')
cd(startDir)

out = fullfile(fdir,outfname);

end