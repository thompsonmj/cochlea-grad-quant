function TOPRO3 = gathertopro3(C)

% Input: C = cell array of cochlea data objects.
% Ountput: pSmad = matrix of all pSmad data.
%          avgpSmad = matrix with just one curve from each cryosection

TOPRO3 = [];

nCoch = numel(C);

for iCoch = 1:nCoch

    nSecs = numel(fieldnames(C{iCoch}.Dat));
    for iSec = 1:nSecs
        secIdx = fieldnames(C{iCoch}.Dat);
        if isfield( C{iCoch}.Dat.(secIdx{iSec}),'TOPRO3')
            TOPRO3 = [TOPRO3, C{iCoch}.Dat.(secIdx{iSec}).TOPRO3.smMnDat];
        end
    end
end

end