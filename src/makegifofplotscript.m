%
% B5RawDat.Sox2

fig = figure;

% x = C20.Dat.B5.OSR.circPsn;
x = C{4}.Dat.B5.OSR.circPsn;

%% EDIT RAW DATA
% rawDat = B5RawDat.TOPRO3;
rawDat = C{4}.Dat.B5.OSR.Sox2.rawDat;
%% EDIT SMOOTHED DATA
% smDatL = B5smDat.TOPRO3;
st=struct;
st.s=rawDat;
smDatL = smoothrawdata(st,x);
smDatL=smDatL.s;
clear smDatL
smDatL = C{4}.Dat.B5.USR.Sox2.algnDat;

nZ = size(C{4}.Dat.B5.USR.Sox2.algnDat,2);

x = x/max(x);

nVals = size(smDatL,1);
maxVals = zeros(nVals,1);
minVals = zeros(nVals,1);

for iVal = 1:nVals
    for iZ = 1:nZ
        minVals(iVal) = min(smDatL(iVal,:));
        maxVals(iVal) = max(smDatL(iVal,:));
    end
end

[~,zMin] = min(min(smDatL));
[~,zMax] = max(max(smDatL));

im_U = cell(nZ,1);

for iZ = 1:nZ
%     plot([0.001:0.001:1],rawDat(:,iZ),'Color','b','LineStyle',':');
    hold on
    plot([0.001:0.001:1],smDatL(:,iZ),'Color','b','LineWidth',2);
    plot([0.001:0.001:1],maxVals,'Color','b','LineStyle','--');
    plot([0.001:0.001:1],minVals,'Color','b','LineStyle','--');
    hold off
    grid on
    fig.Color = 'w';
    xlim([0, max(x)])
    ylim([0, max(max(rawDat))])
%% EDIT TITLE
    title(['C20-B5-Sox2-z',num2str(iZ),' (loess smoothing)']);
    xlabel('x/L');
    ylabel('Intensity [AU]');
    
    M_U = getframe(fig);
    im_U{iZ} = frame2im(M_U); 

end
%% EDIT NAME
M_name = sprintf('C20-B5-Sox2-500.gif');

for idx=1:length(im_U)
    [A,map] = rgb2ind(im_U{idx},256);
        if idx == 1
            imwrite(A,map,M_name,'gif','LoopCount',Inf,'DelayTime',0.5);
        else
            imwrite(A,map,M_name,'gif','WriteMode','append','DelayTime',0.5);
        end
end


