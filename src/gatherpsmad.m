function [psmad,pSmad_mean] = gatherpsmad(C)

% Input: C = cell array of cochlea data objects.
% Ountput: pSmad = matrix of all pSmad data.
%          avgpSmad = matrix with just one curve from each cryosection

pSmad = [];
pSmad_mean = [];
psmad={};

nCoch = numel(C);

for iCoch = 1:nCoch

    nSecs = numel(fieldnames(C{iCoch}.Dat));
    for iSec = 1:nSecs
        secIdcs = fieldnames(C{iCoch}.Dat);
        
        if secIdcs{iSec}(1)=='B'
        
            if isfield( C{iCoch}.Dat.(secIdcs{iSec}).USR,'pSmad')
%                 pSmad = [pSmad, C{iCoch}.Dat.(secIdcs{iSec}).USR.pSmad.algnDat];
%                 pSmad_mean = [pSmad_mean, C{iCoch}.Dat.(secIdcs{iSec}).USR.pSmad.mn];
                psmad=[psmad, C{iCoch}.Dat.(secIdcs{iSec}).OSR.pSmad.rawDat];
            end
            
        end
        
    end
end

end