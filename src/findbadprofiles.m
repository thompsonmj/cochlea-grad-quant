nC = numel(C);

figure
for iC = 1:nC
    hold on
    S = fieldnames(C{iC}.Dat);
    nSecs = numel(S);
    for iSec = 1:nSecs
        plot(C{iC}.Dat.(S{iSec}).USR.pSmad.algnDat,'k','LineStyle',':');
        [peakVal,peakIdx] = max(C{iC}.Dat.(S{iSec}).USR.pSmad.algnDat);
        plot([peakIdx, peakIdx], [0, peakVal], 'k')
        plot([0, peakIdx],[peakVal, peakVal], 'k')
        ylim([0, 2e4])
        title(['C',num2str(iC),' - ','Sec',S{iSec}])
        pause(1)
    end
end