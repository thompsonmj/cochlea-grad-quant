secs = [1,2,5,7,11,13];
nSecs = numel(secs);

pDat = zeros(1000,nSecs);
sDat = zeros(1000,nSecs);
tDat = zeros(1000,nSecs);

% x = zeros(1000,nSecs);

x = repmat([0.001:0.001:1]',1,nSecs);

z = repmat(secs,1000,1);

idx = 0;

S = fieldnames(C20.Dat);

for iSec = 1:nSecs
    idx = idx + 1;
    pDat(:,idx) = C20.Dat.(S{idx}).USR.pSmad.algnDat;
    sDat(:,idx) = C20.Dat.(S{idx}).USR.Sox2.algnDat;
    tDat(:,idx) = C20.Dat.(S{idx}).USR.TOPRO3.algnDat;
%     x(:,idx) = C.Dat.(S{idx}).USR.circPsn;
end


% For absolute x
% [maxX, longestSlide] = max(max(x));
% idx = 0;
% [val,peakIdx_longestSlide] = max(tDat(:,longestSlide));
% x_at_peakIdx = x(peakIdx_longestSlide,longestSlide);
% for iSec = secs(1):secs(nSecs)
%     idx = idx + 1;
%     [val,peakIdx] = max(tDat(:,idx));
%     offset = x_at_peakIdx - x(peakIdx,idx);
%     if idx ~= longestSlide
%         x(:,idx) = x(:,idx) + offset;
%     end
% end

figure
s1 = scatter3(x(:),z(:),sDat(:),2,z(:),'filled');
% colormap(s1,'parula')

maxVal = max( [max(max(sDat)), max(max(pDat)), max(max(tDat))] );
zlim([0, maxVal])

title('Sox2')
xlabel('Position')
ylabel('Section (15 \mum thick)')
zlabel('Intensity')
colorbar
grid on
