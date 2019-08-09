methods = { 'movmean', ...
           'movmedian', ...
           'gaussian', ...
           'lowess', ...
           'loess', ...
           'rlowess', ...
           'rloess', ...
           'sgolay' };
       
nMethods = numel(methods);
nProfiles = numel(out);
figIDs = [1:1:nProfiles];
time = datestr(clock,'HHMMSS');
dirName = ['smoothing_',time];
status = mkdir(dirName);
assert(status)
startDir = pwd;
cd(dirName)

subplot = @(m,n,p) subtightplot(m,n,p,0.04,0.08,0.02 );

for iP = 1:1
    figH = figure(figIDs(iP));
%     [ha,pos] = tight_subplot(2,4,0.05,0.1,0.05);
    for iM = 1:nMethods
        
        subplot(3,4,iM)
        
%         axes(ha(iM));
        
        hold on

        nWins = size(out{iP}.smProfiles_Cell{iM},1);
        winSizes = [2:2:nWins*2]';
        
        xPsn = out{iP}.xPsn;
        pixelsPerMicron = mean(diff(xPsn))^-1;
        winSizesMicrons = winSizes./pixelsPerMicron; % 3.2073 pixels/um
        xMat = repmat(xPsn',nWins,1);
        smProfiles = out{iP}.smProfiles_Cell{iM};
        
        lineColors = jet(nWins);
        colormap(lineColors)
        
        raw = out{iP}.raw;
        normFactor = max(raw);
        rawNorm = raw/normFactor;
        
        for iW = 1:10:nWins
            smNorm = smProfiles(iW,:)/normFactor;
            plot(xMat(iW,:),smNorm, ...
                'Color',lineColors(iW,:), ...
                'LineWidth',1)
        end
        
        plot(xPsn,rawNorm, ...
            'Color','k', ...
            'LineStyle',':', ...
            'LineWidth',1);
        
        opt = out{iP}.optSmDat_Cell{iM};
        optNorm = opt/normFactor;
        plot(xPsn,optNorm, ...
            'Color','k', ...
            'LineWidth',3)
        
        if out{iP}.targ == "TOPRO3"
            ylim([0 1])
        else
            ymin = min(raw)/normFactor;
            ylim([ymin 1])
        end
        
        optWin = out{iP}.optWin_Cell{iM};
        optWinMicrons = round( (optWin/(pixelsPerMicron^1))^1 );
        str = ['Opt. win.: ',num2str(optWinMicrons),'\mum'];
        maxVal = max(rawNorm);
        text(10,maxVal,str)
        
        title(methods{iM})
        xlabel('Position [\mum]')
        ylabel('Fluorescence [AU]')
        
%         set(gca,'XTickLabel',cellstr(num2str(get(gca,'XTick')')))
%         set(gca,'YTickLabel',cellstr(num2str(get(gca,'YTick')'))) 
        
        set(gca,'clim',winSizesMicrons([1,end]));
        cbar = colorbar;
        cbar.Label.String = 'Smoothing Window Size [\mum]';
        
        sgtitle([out{iP}.Cochlea,'_',out{iP}.Section,'_',out{iP}.targ], ...
            'Interpreter', 'none');
        
        hold off
        
    end
    
    % Get the corresponding cochlea image.
    cNo = out{iP}.Cochlea(2:end);
    workDirInfo = dir(fullfile(pwd,'/..'));
    nObjects = length(workDirInfo);
    for iO = 1:nObjects
        str = workDirInfo(iO).name;
        expression = ['^',cNo,'(?=_)'];
        [sIdx,eIdx] = regexp(str,expression);
        if isempty(sIdx)
            continue % Keep checking
        else
            cochDir = str;
            break % Found it
        end
    end
    
    imgDir = fullfile(cochDir,'tif-orient','sep-ch','mip','despeckle','_dat_');
    
    
    
%     figH.Units = 'normalized';
%     figH.OuterPosition = [0 0 1 1];

    fname = [out{iP}.Cochlea,'_',out{iP}.Section,'_',out{iP}.targ];
%     saveas(figure(figIDs(iP)),fname)
    saveas(figH,fname)

    fig = fullfile('..',dirName,[fname,'.fig']);
    fig2img(fig,'png')
    
    close(figH)
    
end

cd(startDir)

%% Histogram
% figure(959),for iM = 1:8,yyaxis right,histogram(optErrMat(iM,:),'BinWidth',100,'EdgeColor',lineColors(iM,:),'LineWidth',2,'FaceColor','none','Normalization','cumcount'),end

%% LOCAL FUNCTIONS
%% SMOOTH PROFILE PLOT
function updateplotLOCAL(xPsn,rawDat,smDat,methods,methIdx,iM,winSizesMicrons,iW,nWins)

lineColors = jet(nWins);
colormap(lineColors);
figure(methIdx(iM))
hold on
plot(xPsn,smDat,'Color',lineColors(iW,:),'LineWidth',1);
plot(xPsn,rawDat,'LineStyle',':','Color','k','LineWidth',1)
set(gca,'clim',winSizesMicrons([1,end]));
cbar = colorbar;
cbar.Label.String = 'Smoothing Window Size [\mum]';
title(methods{iM})
xlabel('Position [\mum]')
ylabel('Fluorescence [AU]')
hold off

end
%% PHASE PLOT
function figID = plotphaseLOCAL(err,errFD,methods,methIdx,iM)

nMeths = numel(methIdx);
figID = nMeths + 1;
lineColors = hsv(nMeths);
colormap(lineColors)
figure(figID)
hold on
plot(err(1:end-1),errFD,'Color',lineColors(iM,:), ...
    'LineStyle','-','LineWidth',1,'Marker','.','MarkerSize',10)
xlabel('RMSE')
ylabel('dRMSE/dWin')
hold off

end
%% OPTIMAL POINT PLOT
function h = plotminsLOCAL(errMin,errFirstDerivMin,methods,methIdx,iM)

nMeths = numel(methIdx);
figID = nMeths + 1;
lineColors = hsv(nMeths);
colormap(lineColors)
figure(figID)
hold on
h = plot(errMin,errFirstDerivMin,'Color',lineColors(iM,:), 'Marker','.','MarkerSize',40);

end
