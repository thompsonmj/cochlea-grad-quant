function out = currentstats( FullRawDat)
%CURRENTSTATS reports the current sample size of each experimental
%condition that data has been acquired for.

cochleae = fields(FullRawDat);
nCochleae = numel(cochleae);

nSecsList = []; % Number of cryosections per cochlea.
nTOPRO3 = zeros(nCochleae,1); % Number of TOPRO3-stained cryosections per cochlea
nSox2 = zeros(nCochleae,1);
nPsmad = zeros(nCochleae,1);
nJag1 = zeros(nCochleae,1);
nBmp4 = zeros(nCochleae,1);

nSP = zeros(nCochleae,1);
nPJ = zeros(nCochleae,1);
nJS = zeros(nCochleae,1);
nBP = zeros(nCochleae,1);

for iC = 1:nCochleae
    sections = fields(FullRawDat.(cochleae{iC}));
    nSecs = numel(sections);
    nSecsList = [nSecsList; nSecs];
    for iS = 1:nSecs
        % Count total number of TOPRO3-stained cochleae.
        targets = fields( FullRawDat.(cochleae{iC}).(sections{iS}) );
        if ismember('TOPRO3', targets)
            nTOPRO3(iC) = nTOPRO3(iC) + 1;
        end
        if ismember('Sox2', targets)
            nSox2(iC) = nSox2(iC) + 1;
        end
        if ismember('pSmad', targets)
            nPsmad(iC) = nPsmad(iC) + 1;
        end
        if ismember('Jag1', targets)
            nJag1(iC) = nJag1(iC) + 1;
        end
        if ismember('Bmp4', targets)
            nBmp4(iC) = nBmp4(iC) + 1;
        end
        
        if ismember('Sox2',targets) && ismember('pSmad',targets)
            nSP(iC) = nSP(iC) + 1;
        end
        if ismember('pSmad',targets) && ismember('Jag1',targets)
            nPJ(iC) = nPJ(iC) + 1;
        end
        if ismember('Jag1',targets) && ismember('Sox2',targets)
            nJS(iC) = nJS(iC) + 1;
        end
        if ismember('Bmp4',targets) && ismember('pSmad',targets)
            nBP(iC) = nBP(iC) + 1;
        end
    end
    
end

out.SecsList = nSecsList;
out.TOPRO3 = nTOPRO3;
out.Sox2 = nSox2;
out.Psmad = nPsmad;
out.Jag1 = nJag1;
out.Bmp4 = nBmp4;
out.SP = nSP;
out.PJ = nPJ;
out.JS = nJS;
out.BP = nBP;

end