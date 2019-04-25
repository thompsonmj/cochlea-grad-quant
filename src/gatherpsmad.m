function [psmad] = gatherpsmad(C)

% Input: C = cell array of cochlea data objects.
% Ountput: pSmad = matrix of all pSmad data.
%          avgpSmad = matrix with just one curve from each cryosection

if isequal(class(C), 'struct')
    C = struct2cell(C);
end

psmad={};

nCoch = numel(C);

for iCoch = 1:nCoch

    nSecs = numel(fieldnames(C{iCoch}.Dat));
    for iSec = 1:nSecs
        secIdcs = fieldnames(C{iCoch}.Dat);
        
        if secIdcs{iSec}(1)=='B' % Specify 'B' for basal and 'A' for apical.
        
            if isfield( C{iCoch}.Dat.(secIdcs{iSec}).USR,'pSmad')
%                 pSmad = [pSmad, C{iCoch}.Dat.(secIdcs{iSec}).USR.pSmad.algnDat];
%                 pSmad_mean = [pSmad_mean, C{iCoch}.Dat.(secIdcs{iSec}).USR.pSmad.mn];
                if ~(iCoch == 8 && isequal(secIdcs{iSec},'B2')) && ...
                    ~(iCoch == 12 && isequal(secIdcs{iSec},'A1') && ...
                    isequal(secIdcs{iSec},'A2') && ...
                    isequal(secIdcs{iSec},'B7') && ...
                    isequal(secIdcs{iSec},'B8') )

                    psmad = [psmad, C{iCoch}.Dat.(secIdcs{iSec}).USR.pSmad.algnDat];
                end
            end
            
        end
        
    end
end

end