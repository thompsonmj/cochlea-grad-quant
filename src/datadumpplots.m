clear
load(fullfile('..','..','..','data','cochlea-data_3_2020-04-01_13-33-24.mat'),'data')
load('colormaps.mat')
figs_dir = fullfile('..','..','..','data','figs_3-micron');
channels = { ...
    'psmad', ...
    'sox2', ...
    'jag1', ...
    'topro3'};
colors = { ...
    psmad_color, ...
    sox2_color, ...
    jag1_color, ...
    'k'};
colormaps = { ...
    cmap_psmad, ...
    cmap_sox2, ...
    cmap_jag1, ...
    cmap_topro3};
subplotRow1Idcs = [1,2,3,4];
subplotRow2Idcs = [5,6,7,8];
nCh = numel(channels);
nS = numel(data);

win = 300;
rMic = 2;

% Using 'cochlea-data_2_2020-04-01_13-51-11.mat' error with iS = 24, 25
% 24, 25
start = 26;
for iS = start:nS
    h = figure('doublebuffer','off','Visible','off');
%     h = figure;
    for iCh = 1:nCh
        ch = channels{iCh};
        %% Set up scaling factor for intensity plots and cochlea section image
        if ~strcmp(ch,'jag1')
            nucIntensities = data(iS).([ch,'_nuc']);
        else
            nucIntensities = [];
        end
        pseIntensities = data(iS).(ch);
        if ~isempty(nucIntensities)
            displayScalingFactor = max(nucIntensities);
        elseif ~isempty(pseIntensities)
            displayScalingFactor = max(pseIntensities);
        end
        %% Image of cochlea section
        %%%%%%%%%%%% Add a row of subplots for PSE 
        subplot(2,4,subplotRow2Idcs(iCh))
        imgFile = data(iS).([ch,'_img_file']);
        if ~isempty(data(iS).nuc_roi) && ...
                ~isempty(imgFile)
            nucRoi = data(iS).nuc_roi;
            pseRoi = data(iS).pse_roi;
            scale = data(iS).img_scale;

            rPxl = round(rMic*scale);
            
            img = double(imread(imgFile));
%             imgDemo = scaleto16bit(img);
            imgDemo = img;
%             imgMax = max(max(imgDemo));
            imgDemo = imgDemo./displayScalingFactor;
            nucXCoords = nucRoi.mfCoordinates(:,1);
            nucYCoords = nucRoi.mfCoordinates(:,2);
            nSamps = numel(nucXCoords);
            %% Set up PSE ROI interpolant
            cx = pseRoi.mnCoordinates(:,1); % X-coordinates for PSE curve nodes
            cy = pseRoi.mnCoordinates(:,2); % Y-coordinates for PSE curve nodes
            xInterp = [min(cx):0.01:max(cx)]; % 'continuous' x-domain for interpolating curve
            yInterp = makima(cx,cy,xInterp);
            %% Overlay sampled pixels
            for iSamp = 1:nSamps
                [xGrid, yGrid] = ...
                    meshgrid(1:size(img,2), 1:size(img,1));
                xCoord = nucXCoords(iSamp);
                yCoord = nucYCoords(iSamp);
                mask = (yGrid - yCoord).^2 + ...
                    (xGrid - xCoord).^2 <= rPxl^2;
                maskIdcs = find(mask);
%                 imgDemo(maskIdcs) = 2^16;
                imgDemo(maskIdcs) = 1;
            end
            %% Project to PSE ROI interpolant
            nInterp = numel(xInterp);
            projectionMeans = nan(nInterp,1);
            projectionSems = nan(nInterp,1);
            lineStartCoords = zeros(nSamps,2);
            lineStopCoords = zeros(nSamps,2);
            for iSamp = 1:nSamps % Loop through each clicked nuclear sample
                d = zeros(nInterp,1);
                for iInterp = 1:nInterp % Loop through each point along the interp curve
                    % calculate the distance between the nuclear point and the curve
                    % point
                    d(iInterp) = ...
                        sqrt((nucXCoords(iSamp) - xInterp(iInterp))^2 + (nucYCoords(iSamp) - yInterp(iInterp))^2);
                end
                % for nucleus number iSamp, isolate the index of the min distance
                % to a point along the interp curve
                [dMin,minIdx] = min(d);

                % Coordinates for start,stopfor  specifying a line connecting sampled
                % nuclear point to its point on the interpolated
                lineStartCoords(iSamp,1) = nucXCoords(iSamp);
                lineStartCoords(iSamp,2) = nucYCoords(iSamp);

                lineStopCoords(iSamp,1) = xInterp(minIdx);
                lineStopCoords(iSamp,2) = yInterp(minIdx);
            end
            % Check ROIs visually.
            f = imagesc(imgDemo);
            colormap(gca,colormaps{iCh});
            hold on

            % Profile curve nodes.
            scatter(cx,cy,30,'w','filled')

            % Profile curve interp.
            plot(xInterp,yInterp, ...
                '-', ...
                'LineWidth', 2, ...
                'Color', 'w')

            % Connecting lines between manualy selected points and profile curve interp.
            for iSamp = 1:nSamps
                x1 = lineStartCoords(iSamp,1);
                x2 = lineStopCoords(iSamp,1);

                y1 = lineStartCoords(iSamp,2);
                y2 = lineStopCoords(iSamp,2);
                plot([x1,x2], [y1,y2], ...
                    'Color', 'w')
            end
            f = addscalebar(f,data(iS).img_scale,50);
        elseif ~isempty(imgFile)  
            img = double(imread(imgFile));
            imgDemo = img;
%             imgMax = max(max(imgDemo));
            imgDemo = imgDemo./displayScalingFactor;
            f = imagesc(imgDemo);
            colormap(gca,colormaps{iCh});
            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            set(gca,'ytick',[])
            set(gca,'yticklabel',[])
            f = addscalebar(f,data(iS).img_scale,50);
        end
        %% PSE ROI
%         if data(iS).original_bit_depth == 8 
%             displayScalingFactor = displayScalingFactor^2;
%         end
        if ~isempty(data(iS).(ch)) && ...
                ~isempty(data(iS).([ch,'_img_file']))
            subplot(2,4,subplotRow1Idcs(iCh))
            y = data(iS).(ch)/displayScalingFactor;
            nPts = numel(y);
            x = (1/nPts:1/nPts:1);
            hold on
            plot(x,smoothrawdata(y,'loess',win),'Color',colors{iCh},'linew',2)
            plot(x,y,'Color',colors{iCh},'linew',1);
            ylim([0,1])
            xticks([0,0.2,0.4,0.6,0.8,1])
            midTick = round(max(y),2);
            if midTick < 1
                yticks([0,1])
            else
                yticks([0,1])
            end
            title(ch)
        end
        %% NUC ROI
        if ~strcmp(ch,'jag1') && ...
                ~isempty(data(iS).([ch,'_nuc']))
            hold on
            errorbar(data(iS).x_nuc, data(iS).([ch,'_nuc'])./displayScalingFactor, ...
                data(iS).([ch,'_nuc_sem'])./displayScalingFactor, 'o', ...
                'MarkerEdgeColor',colors{iCh}, ...
                'Color',colors{iCh})
            plot(data(iS).x_nuc, smoothrawdata(data(iS).([ch,'_nuc'])./displayScalingFactor,'movmean',20),'linew',4,'Color',colors{iCh},'lines',':')
        end        
    end
    truesize
    saveas(h,fullfile(figs_dir,['E',num2str(data(iS).age),'C',num2str(data(iS).cochlea_idx),'B',num2str(data(iS).section_idx),'.png']))
    close all
end