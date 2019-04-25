nC = numel(C);

rawB = zeros(1000,1);
rawA = zeros(1000,1);
meanB = zeros(1000,1);
meanA = zeros(1000,1);
stdB = zeros(1000,1);
stdA = zeros(1000,1);
nBs = [];
nAs = [];

for iC = 1:nC
    try
        [rB,rA,mB,mA,sB,sA,nB,nA] = organstats(C{iC}, 'Sox2');
    catch
        warning(['Problem with ',num2str(iC)])
        continue
    end
    rawB = [rawB, rB];
    rawA = [rawA, rA];
    meanB = [meanB, mB];
    meanA = [meanA, mA];
    stdB = [stdB, sB];
    stdA = [stdA, sA];
    nBs = [nBs, nB];
    nAs = [nAs, nA];
end

idx = [];
nC = size(meanB,2);
for iC = 1:nC
    if mean(diff(meanB(:,iC))) == 0
        idx = [idx, iC];
    end
end

% figure,plot(meanB)
% size(meanB)
meanB(:,idx) = [];
% figure,plot(meanB)
% size(meanB)

NormB = normdat(meanB);
normB = NormB.chiSq;
% normB(:,5)=[];
maxTmp = max(mean(normB,2));
minTmp = min(mean(normB,2));
normB = (normB - minTmp)/(maxTmp - minTmp);

normBS = normB;
