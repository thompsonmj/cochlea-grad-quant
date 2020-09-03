function [xOut,yOut,errOut] = ...
    projectnuclearsamplestoroicurve(nucFile,pseFile,rMic,scale,imgFile)
%PROJECTNUCLEARSAMPLESTOROICURVE projects nuclear samples to an ROI curve.
%
% Usage: [xOut,yOut] = projectnuclearsamplestoroicurve(ptsFile,curveFile.roi,varargin);
% E.g. [xOut,yOut] = ...
% projectnuclearsamplestoroicurve( ...
%   'ptsFile.roi', ...
%   'curveFile.roi', ...
%   'ch1.tif', ...
%   'ch2.tif');
%
% Input:
%   > ptsFile: Nuclear sample points *.roi file
%   > curveFile: Curve to project sampled data onto *.roi file
%   > scale: image scael [pixels/µm]
%   > img_file: Image files for channels to project (>=1, 'imread' compatible)
% 
% Output:
%   > xOut: array of normalized sample x-coordinates along the PSE projection
%   > yOut: array of sampled absolute intensities
%%% ^^^ Need to format better w/ more metadata


%% Read inputs
% Read ROIs
% ptsFile = '20_B7_pse_points.roi';
nucRoi = nucFile;
nucXCoords = nucRoi.mfCoordinates(:,1);
nucYCoords = nucRoi.mfCoordinates(:,2);

% curveFile = '20_B7_pse_1-width.roi';
pseRoi = pseFile;
cx = pseRoi.mnCoordinates(:,1); % X-coordinates for PSE curve nodes
cy = pseRoi.mnCoordinates(:,2); % Y-coordinates for PSE curve nodes
xInterp = [min(cx):0.01:max(cx)]; % 'continuous' x-domain for interpolating curve
 % xInterp units are pixels: min and max are the left-most and right-most
 % x-value pixel indices of ROI curve for the image

% Reconstruct ROI curve using piecewise cubic Hermite interpolating polynomial
% cs = makima(cx(1:end),cy(1:end)); % Start at 2 to avoid a strange artifact
% yInterp = ppval(cs,xInterp);

try
    yInterp = makima(cx,cy,xInterp);
catch
    disp('ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR ERROR')
    pause(10)
end
nSamps = numel(nucXCoords);
%% Set radius around sample point to take the mean intensity for.
% rMic = 1;
rPxl = round(rMic*scale);
%% Collect signal samples at each of the chosen points for each channel.
% https://www.mathworks.com/matlabcentral/answers/161113-how-can-i-get-the-values-of-a-circular-region-around-a-particular-pixel
%   and
% https://matlab.fandom.com/wiki/FAQ#How_do_I_create_a_circle.3F

img = double(imread(imgFile));
imgDemo = scaleto16bit(img);
meanSampVals = zeros(nSamps,1); 
semSampVals = zeros(nSamps,1);

for iSamp = 1:nSamps

    [xGrid, yGrid] = ...
        meshgrid(1:size(img,2), 1:size(img,1));
%         xGrid: [1, 2, 3, 4, ...
%                 1, 2, 3, 4, ...
%                 1, 2, 3, 4, ...
%                 1, 2, 3, 4, ...]
% 
%         yGrid: [1, 1, 1, 1, ...
%                 2, 2, 2, 2, ...
%                 3, 3, 3, 3, ...
%                 4, 4, 4, 4, ...]
    xCoord = nucXCoords(iSamp);
    yCoord = nucYCoords(iSamp);
    mask = (yGrid - yCoord).^2 + ...
        (xGrid - xCoord).^2 <= rPxl^2;
    maskIdcs = find(mask);
    imgDemo(maskIdcs) = 2^16;
    values = img(maskIdcs);
    meanSampVals(iSamp) = mean(values);
    semSampVals(iSamp) = std(values)/sqrt(numel(values));
end
%% Find closest point on the interpolant to each nuclear point.
nInterp = numel(xInterp);
% % % d = zeros(nSamps*nInterp,1);
% Cell array holding sampled nuclear intensities arranged at indicies
% matching positions along the interpolated linear profile.
% projections = cell(nCh,1);
% lineStartCoords = cell(nCh,1);
% lineStopCoords = cell(nCh,1);

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
    %%% Add a check to ensure it's approximately at a right angle
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

    % Assign the intensity value for nucleus iSamp to the index of the
    % point along the interp curve
    projectionMeans(minIdx) = meanSampVals(iSamp);
    projectionSems(minIdx) = semSampVals(iSamp);
end
projectionMeans(projectionMeans == 0) = nan;
projectionSems(projectionSems == 1) = nan;

%% Check ROIs visually.
% f = figure;
% % img = imread(imgFile);
% imagesc(imgDemo)
% hold on
% 
% % Manually selected points.
% scatter(nucXCoords,nucYCoords,rPxl,'w')
% 
% % Profile curve nodes.
% scatter(cx,cy,30,'w','filled')
% 
% % Profile curve interp.
% plot(xInterp,yInterp, ...
%     '-', ...
%     'LineWidth', 2, ...
%     'Color', 'w')
% 
% % Connecting lines between manualy selected points and profile curve interp.
% for iSamp = 1:nSamps
%     x1 = lineStartCoords(iSamp,1);
%     x2 = lineStopCoords(iSamp,1);
% 
%     y1 = lineStartCoords(iSamp,2);
%     y2 = lineStopCoords(iSamp,2);
%     plot([x1,x2], [y1,y2], ...
%         'Color', 'w')
% end
% 
% truesize(f)
% 
%     lineStartCoords(iSamp,1)
%     lineStartCoords(iSamp,2)
%     lineStopCoords(iSamp,1)
%     lineStopCoords(iSamp,2)
% 
% pause(0.5)
% close(f)
%% Plot projected intensities
% chanProjNorms = cell(nCh,1);
% normProf = cell(nCh,1);
cMap = hsv;
[d1,~] = size(cMap);
% div = round(d1/nCh);

% ax = zeros(nCh,1);

% dataFig = figure;

xInterpNorm = xInterp/max(xInterp);

%% Quantified profile curve and figure generation
projNorms = (projectionMeans - min(projectionMeans))/ ...
    (max(projectionMeans) - min(projectionMeans));

%     figure(dataFig)
%     hold on
%     ax(iCh) = ...
%         scatter(xInterpNorm,chanProjNorms{iCh}, ... 
%         10,cMap(div*iCh,:));
%         scatter(xInterp(1:end-1)/max(xInterp(1:end-1)),normCh{iCh},10,cMap(div*iCh,:));

[idcsProjNorm,~] = find(~isnan(projNorms));

xNew = xInterp(idcsProjNorm); % Pixel x-indices for each nuclei's projected location to the prosensory epithelium curve
xOut = xNew/max(xNew); % Normalized

yOut = projectionMeans(idcsProjNorm);
errOut = projectionSems(idcsProjNorm);
    
    %% Binned approach
% %     [N,edges] = histcounts(chanProjNorms{iCh}(idcsChanProjNorm));
% %     figure
% %     h = histogram(chanProjNorms{iCh}(idcsChanProjNorm));
%     nBins = 20;
%     y = chanProjNorms{iCh}(idcsChanProjNorm);
%     nY = numel(y);
%     [~,E] = discretize(y,nBins);
%     yBinned = zeros(nBins,1);
%     for iB = 1:nBins
%         yBinned(iB) = mean(y():());
%     end
    %% Smoothed approach
%     % SENSITIVE TO CHOICE OF SMOOTHING ALGORITHM AND PARAMETERIZATION
%     meanProf = smoothrawdata(y,'loess',10);
% %     meanProf = smoothdata(chanProjNorm{iCh}(idxCh),'loess');
%     normProf{iCh} = meanProf;
% 
%     plot(xNew,meanProf,'Color',cMap(div*iCh,:),'LineWidth',2)
    
% end

% figure(dataFig)
% legend(ax,varargin,'Interpreter','none')

% out = normProf;


%% Optimal smoothing comparison
% % clear some space
% clearvars -except xNew pProf sProf
% load('smoothData.mat')
% % load('Z:\cochlea\data\img\sw\wt\E12.5\SmOptE12.mat')
% 
% % C20 is out{59}:out{70}
% % 68: B7 pSmad
% pSm = smoothData.optSmDat_Cell{5};
% pSm = (pSm - min(pSm))/(max(pSm) - min(pSm));
% 
% [~,idx] = max(pSm);
% pSm = pSm(1:idx);
% 
% xPsn = smoothData.xPsn;
% xPsn = xPsn(1:idx);
% xPsn = xPsn/max(xPsn);
% 
% figure(50)
% hold on
% plot(xPsn,pSm,'color','r','lines',':')
% 
% %% Try deconvolution
% lambda = 6300; % Determined from L-curve
% hhat = deconvPurdue(prof, uniformsample(pSm,numel(prof)), 100, lambda);


end