function validTF = checkifvalidroitype ( roiType )
% CHECKIFVALIDROITYPE indicates whether roiType names are valid.
%
% Input:
%   > roiType: String.
% Output:
%   > validtf: true/false indicating if inputs match a master list in
%   VALIDROITYPE.csv

VALIDENTRYFILE = 'VALIDROITYPE.csv';

validEntry = delimread(VALIDENTRYFILE,',','text') %delimread is custom function
validEntry = validEntry.text; 
nT = numel(roiType);

if ismember(roiType, validEntry)
    validTF = true;
else
    validTF = false;
    return
end


end