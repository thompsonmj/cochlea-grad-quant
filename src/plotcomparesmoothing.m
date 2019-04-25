% Cochlea data must be loaded into workspace.

coch = 2;

Ctest = C{coch};
S = fieldnames(Ctest.Dat);
T = {'Sox2','pSmad','TOPRO3'};
nS = numel(S);
x = cell(nS,1);
sox2 = cell(nS,1);
psmad = cell(nS,1);
topro3 = cell(nS,1);
for iS = 1:nS
    x{iS} = Ctest.Dat.(S{iS}).OSR.circPsn;
    sox2{iS} = maxintproj(Ctest.Dat.(S{iS}).OSR.Sox2.rawDat);
    psmad{iS} = maxintproj(Ctest.Dat.(S{iS}).OSR.pSmad.rawDat);
    topro3{iS} = maxintproj(Ctest.Dat.(S{iS}).OSR.TOPRO3.rawDat);
end

for iS = 1:nS
    xIn = x{iS};
    RawDat.Sox2 = sox2{iS};
    RawDat.pSmad = psmad{iS};
    RawDat.TOPRO3 = topro3{iS};
    
%     3.2073 pixels per micron
    smDat1 = smoothrawdata(RawDat, xIn, 'sgolay',100);
    smDat2 = smoothrawdata(RawDat, xIn, 'loess',100);

    maxS = max(max(sox2{iS}));
    minS = min(min(sox2{iS}));
    maxP = max(max(psmad{iS}));
    minP = min(min(psmad{iS}));
    maxT = max(max(topro3{iS}));
    minT = min(min(topro3{iS}));
    
    figure
    plot(x{iS}, sox2{iS}/maxS,'b','LineStyle',':')
    hold on
    plot(x{iS}, smDat1.Sox2/maxS,'Color',[0,0,0.9],'LineWidth',2)
    plot(x{iS}, smDat2.Sox2/maxS,'Color',[0,0,0.4],'LineWidth',2)
    xlim([0, max(x{iS})])
    ylim([0, 1])
    xlabel('Circ. Position [\mum]')
    ylabel('Fluorescence')
    title(['Sox2 ',S{iS}])
    legend('raw','sgolay','loess')
    grid on
    
    figure
    plot(x{iS}, psmad{iS}/maxP,'r','LineStyle',':')
    hold on
    plot(x{iS}, smDat1.pSmad/maxP,'Color',[0.9,0,0],'LineWidth',2)
    plot(x{iS}, smDat2.pSmad/maxP,'Color',[0.4,0,0],'LineWidth',2)
    xlim([0, max(x{iS})])
    ylim([0, 1])
    xlabel('Circ. Position [\mum]')
    ylabel('Fluorescence')
    title(['pSmad ',S{iS}])
    legend('raw','sgolay','loess')
    grid on
    
    figure
    plot(x{iS}, topro3{iS}/maxT,'k','LineStyle',':')
    hold on
    plot(x{iS}, smDat1.TOPRO3/maxT,'Color',[0.1,0.1,0.1],'LineWidth',2)
    plot(x{iS}, smDat2.TOPRO3/maxT,'Color',[0.5,0.5,0.5],'LineWidth',2)
    xlim([0, max(x{iS})])
    ylim([0, 1])
    xlabel('Circ. Position [\mum]')
    ylabel('Fluorescence')
    title(['TOPRO3 ',S{iS}])
    legend('raw','sgolay','loess')
    grid on
end

