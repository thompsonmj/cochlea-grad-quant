x
meanp
nPts = numel(x);

umPerPt = 535.7/1000;

binTot = 10;

PI = zeros(binTot,1);
nBinsList = zeros(binTot,1);

for iBin = 1:binTot
    nBins = nPts/iBin;
    nBinsList(iBin) = nBins;
    xDisc = discretize(x,round(nBins));
    meanpDisc = discretize(meanp,round(nBins));
    PI(iBin) = mutInfo(xDisc,meanpDisc);
end

figure
scatter(nBinsList,PI)