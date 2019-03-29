function [Sox2,Sox2_mean] = gathersox2(C)

% Input: C = cell array of cochlea data objects.
% Ountput: pSmad = matrix of all pSmad data.
%          avgpSmad = matrix with just one curve from each cryosection

Sox2 = [];
Sox2_mean = [];

nCoch = numel(C);

for iCoch = 1:nCoch
    
    nSecs = numel(fieldnames(C{iCoch}.Dat));
    for iSec = 1:nSecs
        secIdcs = fieldnames(C{iCoch}.Dat);

        if secIdcs{iSec}(1)=='B'
            if isfield( C{iCoch}.Dat.(secIdcs{iSec}).USR,'Sox2')
                if isfield(C{iCoch}.Dat.(secIdcs{iSec}).USR.Sox2, 'algnDat')
                    Sox2  = [Sox2, C{iCoch}.Dat.(secIdcs{iSec}).USR.Sox2.algnDat];
                    Sox2_mean   = [Sox2_mean, C{iCoch}.Dat.(secIdcs{iSec}).USR.Sox2.mn];
                end
            end
            
        end
    end
end

end