function x = gatherx(C)

% Input: C = cell array of cochlea data objects.
% Ountput: pSmad = matrix of all pSmad data.
%          avgpSmad = matrix with just one curve from each cryosection

x = {};

nCoch = numel(C);

for iCoch = 1:nCoch

    nSecs = numel(fieldnames(C{iCoch}.Dat));
    for iSec = 1:nSecs
        secIdcs = fieldnames(C{iCoch}.Dat);
        
        if secIdcs{iSec}(1)=='B'
        
            x = [x,C{iCoch}.Dat.(secIdcs{iSec}).OSR.circPsn];
 
            
        end
        
    end
end

end