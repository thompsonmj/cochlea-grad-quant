function f = visualizenuclearsamples(nucRoi,pseRoi,rMic,scale,imgFile)

rPxl = round(rMic*scale);

img = double(imread(imgFile));
imgDemo = scaleto16bit(img);
nucXCoords = nucRoi.mfCoordinates(:,1);
nucYCoords = nucRoi.mfCoordinates(:,2);
nSamps = numel(nucXCoords);

%% Set up PSE ROI interpolant
cx = pseRoi.mnCoordinates(:,1); % X-coordinates for PSE curve nodes
cy = pseRoi.mnCoordinates(:,2); % Y-coordinates for PSE curve nodes
xInterp = [min(cx):0.01:max(cx)]; % 'continuous' x-domain for interpolating curve
try
    yInterp = makima(cx,cy,xInterp);
catch
    disp('MAKIMA ERROR')
    pause(10)
end

%% Overlay sampled pixels
for iSamp = 1:nSamps

    [xGrid, yGrid] = ...
        meshgrid(1:size(img,2), 1:size(img,1));
    xCoord = nucXCoords(iSamp);
    yCoord = nucYCoords(iSamp);
    mask = (yGrid - yCoord).^2 + ...
        (xGrid - xCoord).^2 <= rPxl^2;
    maskIdcs = find(mask);
    imgDemo(maskIdcs) = 2^16;
end
%% Project to PSE ROI interpolant
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
end
%% Check ROIs visually.
f = figure;
imagesc(imgDemo)
hold on

% % Manually selected points.
% scatter(nucXCoords,nucYCoords,rPxl,'w')

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

truesize(f)
end