function validTF = checkifvalidtargets ( targets )
% CHECKIFVALIDTARGETS indicates whether imaging target names are valid or
% have errors.
%
% Input:
%   > targets: 1D cell array of targets containing strings.
% Output:
%   > validtf: true/false indicating if inputs match a master list in
%   VALIDTARGETS.csv

VALIDTARGETFILE = 'VALIDTARGETS.csv';

validTargets = delimread(VALIDTARGETFILE,',','text');

nT = numel(targets);

for iT = 1:nT
    if ismember(targets(iT), validTargets.text)
        validTF = true;
    else
        validTF = false;
        return
    end
end

end