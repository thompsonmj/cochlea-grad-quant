%% Use C5B2 for debugging
% Use consolidaterawdata.m to make a struct for only this section.
% c5b2 = data([data.cochlea_idx] == 5);
% c5b2 = c5b2([c5b2.section_idx] == 2);
load(fullfile('..','..','..','data','c5b2.mat'))

channels = {'psmad','sox2','topro3'};

%% Project nuclear samples
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
nCh = 3;
for iCh = 1:nCh
    [ c5b2.x_nuc, yyy ] = ...
        projectnuclearsamplestoroicurve( ...
        c5b2.nuc_roi, ...
        c5b2.pse_roi, ...
        c5b2.img_scale, ...
        c5b2.([channels{iCh},'_img_file']) );
end
%% Check ROIs visually.
% for iCh = 1:nCh
%     f = figure;
%     img = imread(varargin{iCh});
%     imagesc(img)
%     hold on
% 
%     % Manually selected points.
%     scatter(nucXCoords,nucYCoords,rPixels,'w')
% 
%     % Profile curve nodes.
%     scatter(cx,cy,30,'w','filled')
% 
%     % Profile curve interp.
%     plot(xInterp,yInterp, ...
%         '-', ...
%         'LineWidth', 2, ...
%         'Color', 'w')
% 
%     % Connecting lines between manualy selected points and profile curve interp.
%     for iSamp = 1:nSamps
%         x1 = lineStartCoords{1}(iSamp,1);
%         x2 = lineStopCoords{1}(iSamp,1);
% 
%         y1 = lineStartCoords{1}(iSamp,2);
%         y2 = lineStopCoords{1}(iSamp,2);
%         plot([x1,x2], [y1,y2], ...
%             'Color', 'w')
%     end
% 
%     truesize(f)
% 
%     lineStartCoords{iCh}(iSamp,1)
%     lineStartCoords{iCh}(iSamp,2)
%     lineStopCoords{iCh}(iSamp,1)
%     lineStopCoords{iCh}(iSamp,2)
% 
% end