function Sox2 = gathersox2(C)

% Input: C = cell array of cochlea data objects.
% Ountput: pSmad = matrix of all pSmad data.
%          avgpSmad = matrix with just one curve from each cryosection

Sox2 = [];

nCoch = numel(C);

for iCoch = 1:nCoch

    nSecs = numel(fieldnames(C{iCoch}.Dat));
    for iSec = 1:nSecs
        secIdx = fieldnames(C{iCoch}.Dat);
        if isfield( C{iCoch}.Dat.(secIdx{iSec}),'Sox2')
            Sox2 = [Sox2, C{iCoch}.Dat.(secIdx{iSec}).Sox2.smMnDat];
        end
    end
end

end