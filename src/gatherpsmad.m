function pSmad = gatherpsmad(C)

% Input: C = cell array of cochlea data objects.
% Ountput: pSmad = matrix of all pSmad data.
%          avgpSmad = matrix with just one curve from each cryosection

pSmad = [];

nCoch = numel(C);

for iCoch = 1:nCoch

    nSecs = numel(fieldnames(C{iCoch}.Dat));
    for iSec = 1:nSecs
        secIdx = fieldnames(C{iCoch}.Dat);
        if isfield( C{iCoch}.Dat.(secIdx{iSec}),'pSmad')
            pSmad = [pSmad, C{iCoch}.Dat.(secIdx{iSec}).pSmad.smMnDat];
        end
    end
end

end