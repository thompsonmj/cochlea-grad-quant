function id = getsectionid(sectionExcelFile)
%GETSECTIONID

% Input
%   > e.g. '..\..\..\data\img\sw\wt\E12.5\14_SW18-1AB_topro3-sox2-psmad\tif-orient\sep-ch\mip\despeckle\quant-prof\B1_pse.xlsx'


id = struct( ...
    'age',          [], ...
    'cochlea_idx',  [], ...
    'section_ab',   [], ...
    'section_idx',  [] );

[loc,name,~] = fileparts(sectionExcelFile);

id.age = str2double(loc(26:29));

str = loc(31:end);
expression = '^\d+(?=_)';
[startIdx,endIdx] = regexp(str,expression);

id.cochlea_idx = str2double(str(startIdx:endIdx));

id.section_ab = name(1);

str = name(2:end);
expression = '^\d+(?=_)';
[startIdx,endIdx] = regexp(str,expression);

id.section_idx = str2double(str(startIdx:endIdx));

end