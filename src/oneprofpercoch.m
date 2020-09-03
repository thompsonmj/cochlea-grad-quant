
data = FullRawDat;

methods = { 'movmean', ...
           'loess', ...
           'sgolay' };
       
C = ["C2",  "C4", "C5", "C9", "C14", "C16", "C17", "C20", "C21", ...
    "C23", "C27", "C28", "C29", "C30", "C31", "C32", "C33", "C43"];
S = ["B11", "B6", "B2", "B2", "B2",  "B6",  "B3",  "B7",  "B3",  ...
    "B1",  "B4",  "B6",  "B1",  "B6",  "B2",  "B2",  "B4",  "B2"];

nProfilesTotal = numel(fields(data));
nProfilesUsed = numel(C);

for iP = 1:nProfilesUsed
    Sec{iP} = [C{iP},'.',S{iP},'_pse'];
end

ypTotal = [];
ypTotalN = [];
ysTotal = [];
ysTotalN = [];
ytTotal = [];
ytTotalN = [];

Cochleae = fieldnames(data);

xLengths = zeros(nProfilesUsed,1);
nPts = 1000;

yhat = zeros(nPts,nProfilesUsed);


for iP = 1:nProfilesUsed
        
    y = data.(C{iP}).([S{iP},'_pse']).pSmad.data;
    nref = data.(C{iP}).([S{iP},'_pse']).TOPRO3.data;
    x = data.(C{iP}).([S{iP},'_pse']).pSmad.xPsn;
    y = uniformsample(y,nPts);
    nref = uniformsample(nref,nPts);
    yhat_temp = regressnoise(nref,y);
%     yhat(:,iP) = smoothrawdata(yhat_temp,'movmean',30);
    yhat(:,iP) = yhat_temp;
    x = uniformsample(x,nPts);
    xLengths(iP) = max(x);
    disp(['Coch:',num2str(iP),' | ',C{iP},' ',S{iP}])
%             pause(2)

end

% norm = normdat(yhat);
% norm = norm.chiSq;
yhatSm = zeros(size(yhat));
for i=1:18
    yhatSm(:,i)=smoothrawdata(yhat(:,i),'loess',400);
end
% norm = normdat(yhatSm);
% norm = normdat(yhat);
% norm = norm.chiSq;
norm = yhatSm;
norm_mean = mean(norm,2);

norm = (norm-min(norm_mean))/(max(norm_mean)-min(norm_mean));

norm100to750 = norm(100:750,:);
normFull = norm;

x100to750 = 0.1:0.001:0.75;
xFull = 0.001:0.001:1;

figure(30)
h100to750_2 = histogram2(repmat(x100to750',1,18),norm100to750, ...
    'Normalization','probability', ...
    'DisplayStyle','tile', ...
    'ShowEmptyBins','on');
colormap 'gray'
colorbar

figure(40)
hFull_2 = histogram2(repmat(xFull',1,18),normFull, ...
    'Normalization','probability', ...
    'DisplayStyle','tile', ...
    'ShowEmptyBins','on');
colormap 'gray'
colorbar

