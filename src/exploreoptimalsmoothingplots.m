clearvars -except out

if ~exist('out')
    SmOptPath = 'F:\projects\cochlea\data\img\sw\wt\E12.5\SmOpt.mat';
    load(SmOptPath)
end

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

subplot = @(m,n,p) subtightplot(m,n,p,0.05,0.08,0.02 );

for iP = 173:nProfiles
    worker = getCurrentWorker;
    subplotsH = figure(figIDs(iP));
    subplotsH.Units = 'Normalized';
    subplotsH.OuterPosition = [0, 0, 1, 1];
    for iM = 1:nMethods
        
        subplot(4,2,iM)
                
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
            'LineWidth',4)
        
        if out{iP}.targ == "TOPRO3"
            ylim([0,1])
        else
            ymin = min(raw)/normFactor;
            ylim([ymin,1])
        end
        
        optWin = out{iP}.optWin_Cell{iM};
        optWinMicrons = round( (optWin/(pixelsPerMicron^1))^1 );
        str = ['Opt. win.: ',num2str(optWinMicrons),'\mum'];
        maxVal = max(rawNorm);
        text(10,maxVal,str)
        
        title(methods{iM})
        xlabel('Position [\mum]')
        ylabel('Fluorescence [AU]')
                
        set(gca,'clim',winSizesMicrons([1,end]));
        cbar = colorbar;
        cbar.Label.String = 'Smoothing Window Size [\mum]';
        
        sgtitle([out{iP}.Cochlea,'_',out{iP}.Section,'_',out{iP}.targ], ...
            'Interpreter', 'none');
        
        hold off
        
    end
    
    %% Get the corresponding cochlea image.
    
%     subplot(3,4,10:11)
    
    cNo = out{iP}.Cochlea(2:end);
    w = what('..');
    workPath = w.path;
    workDirInfo = dir(workPath);
    nObjects = length(workDirInfo);
    for iO = 1:nObjects
        str = workDirInfo(iO).name;
        expression = ['^',cNo,'(?=_)'];
        [sIdx,eIdx] = regexp(str,expression);
        if isempty(sIdx)
            continue % Keep checking
        else
            cochDir = str;
            w = what(fullfile('..',cochDir));
            cochPath = w.path;
            break % Found it
        end
    end
    
    imgDir = fullfile(cochDir,'tif-orient','sep-ch','mip','despeckle','_dat_');
    w = what(fullfile('..',imgDir));
    imgDirPath = w.path;
    
    % Find correct image file and add to subplot.
    sec = out{iP}.Section;
    targ = out{iP}.targ;
    imgDirInfo = dir(fullfile(imgDirPath,'*.tif'));
    nObjects = length(imgDirInfo);
    for iO = 1:nObjects
        str = imgDirInfo(iO).name;
        expression1 = ['^',sec,'.+',targ,'_mip.tif'];
        expression2 = ['^',sec,'.+',targ,'_mip_despeckled'];
        [sIdx1,eIdx1] = regexp(str,expression1,'ignorecase');
        [sIdx2,eIdx2] = regexp(str,expression2,'ignorecase');
        if isempty(sIdx1) && isempty(sIdx2)
            continue % Keep checking
        elseif isempty(sIdx2) && ~isempty(sIdx1)
            imgFile = str; % Found a non-despeckled image.'
            break
        elseif isempty(sIdx1) && ~isempty(sIdx2)
            imgFile = str; % Found a despeckled image.
            break
        end
    end
    
    imgFilePath = fullfile(imgDirPath,imgFile);
    
    img = imread(imgFilePath);
% % %     hImg = axes('Position', [0.35, 0.05, 0.3, 0.28]);
    
    hold on
    
%     img = flipdim(img,1);
    figCochleaH = figure(iP + nProfiles);
% % %     imagesc(hImg,img);
    imagesc(img);
    truesize
% % %     set(hImg,'XTick',[])
% % %     set(hImg,'YTick',[])
    colormap(figCochleaH,'bone')
    
    % Overlay ROI
    try
        roiPath = fullfile(imgDirPath,[sec,'.roi']);
        roi = ReadImageJROI(roiPath);
        x = roi.mnCoordinates(:,1);
        y = roi.mnCoordinates(:,2);
        xx = [min(x):max(x)];
        yy = spline(x,y,xx);
        hold on
        plot(x,y, ...
            '.', ...
            'MarkerSize',10, ...
            'Color','w')
        set(gca,'YDir','reverse')
        plot(xx,yy, ...
            'LineWidth', 1, ...
            'Color','w')
            set(gca,'YDir','reverse')
            
                warning('off', 'Images:initSize:adjustingMag');
    %     truesize
        splineH = plot(xx,yy, ...
            'LineWidth', 0.5*roi.nStrokeWidth, ...
            'Color', 'w');
            set(gca,'YDir','reverse')

        splineH.Color(4) = 0.2;
        
    catch
        str = ['ROI file not found for ',roiPath];
        warning(['ROI file not found for',roiPath])
        t = text(10,maxVal,str);
        t.Interpreter = 'none';
        t.Color = 'red';
%         img = flip(img);
%         cochImgH = imagesc(figCochleaH,img);
    end

    figCochleaH.Children.XTick = [];
    figCochleaH.Children.YTick = [];
    
    hold off
    
    subplotsfname = [out{iP}.Cochlea,'_',out{iP}.Section,'_',out{iP}.targ,'_plots'];
    cochleafname = [out{iP}.Cochlea,'_',out{iP}.Section,'_',out{iP}.targ,'_cochlea'];
%     saveas(figure(figIDs(iP)),fname)
    saveas(subplotsH,subplotsfname,'png')
    saveas(figCochleaH,cochleafname,'png')

%     fig = fullfile('..',dirName,[subplotsfname,'.fig']);
%     fig2img(fig,'png')
    
    close(subplotsH)
    close(figCochleaH)
    
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
