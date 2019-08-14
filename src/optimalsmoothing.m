function [out] = optimalsmoothing(rawDat,xPsn,winStep)
% % % FIXME
% % % %OPTIMALSMOOTHING Smooths a profile using all built-in algorithms using the
% % % %optimal choice of window size and method for the RMSE-dRMSE/dWin phase
% % % %diagram.
% % % 
% % % % Input:
% % % %   > rawDat: raw columnar profile data to be smoothed.
% % % %   > xPsn: Raw position data for this cryosection. Used for
% % % %   setting window size.
% % % %   > winStep: Step size between window sizes.
% % % 
% % % % Output:
% % % %   > smDat: Smooth data struct complimentary to RawDat.
% % % %   > pars: struct specifying the smoothing method, window size, etc.
% % % FIXME
tic
methods = { 'movmean', ...
           'movmedian', ...
           'gaussian', ...
           'lowess', ...
           'loess', ...
           'rlowess', ...
           'rloess', ...
           'sgolay' };
nMethods = numel(methods);
methIdx = [1:nMethods];

winSizes = [10 : winStep : numel(rawDat)]';
pixelsPerMicron = mean(diff(xPsn))^-1;
winSizesMicrons = winSizes./pixelsPerMicron; % 3.2073 pixels/um
nWins = numel(winSizes);

%% Allocate for each method.
% Matrix holding smoothed profiles for each window. 1 per method.
smProfiles_Mat = zeros( size(winSizes,1), numel(rawDat) );
%   Rows: window size
%   Cols: data points along x-axis

% Array holding RMSD of smoothed profile. 1 per method.
rmsd_Arr = zeros( size(winSizes,1), 1 );
%   Rows: RMSD value for a window size
%   Cols: 1

% Array holding NRMSD of smoothed profile. 1 per method.
normRmsd_Arr = zeros( size(winSizes,1), 1 );
%   Rows: NRMSD value for a window size, normalized to min and max for all
%   window sizes.
%   Cols: 1

% Array holding d(RMSD)/d(Win) of smoothed profile. 1 per method.
dRmsd_dWin_Arr = zeros( size(winSizes,1) - 1, 1 );
%   Rows: d(RMSD)/d(Win) value for a window size
%   Cols: 1
%% Allocate containers for each method.
out.smProfiles_Cell = cell(nMethods,1);
out.rmsd_Cell = cell(nMethods,1);
out.nrmsd_Cell = cell(nMethods,1);
out.dRmsd_dWin_Cell = cell(nMethods,1);
out.dNrmsd_dWin_Cell = cell(nMethods,1);
out.rmsdProduct_Cell = cell(nMethods,1);
out.nrmsdProduct_Cell = cell(nMethods,1);
%% Execute
for iM = 1:nMethods
    disp(methods{iM})
    parfor iW = 1:nWins
        %% Smooth and plot smoothed profiles.
        smDat = smoothrawdata( rawDat, methods{iM}, winSizes(iW) );
        smProfiles_Mat(iW,:) = smDat';
%         updateplotLOCAL(xPsn,rawDat,smDat,methods,methIdx,iM, ...
%              winSizesMicrons,iW,nWins);
        %% Calculate error.
        rmsd_Arr(iW) = sqrt(immse( smDat, rawDat ));        
    end
    %% Normalize error across all window sizes for this profile.
    nrmsd_Arr = rmsd_Arr/(max(rmsd_Arr) - min(rmsd_Arr));
    
    %% Pack data into cells for output, and determine optimal settings.
    out.smProfiles_Cell{iM} = smProfiles_Mat;

    out.rmsd_Cell{iM} = rmsd_Arr;
    out.nrmsd_Cell{iM} = nrmsd_Arr;

    dRmsd_dWin_Arr = diff(rmsd_Arr, 1);
    out.dRmsd_dWin_Cell{iM} = dRmsd_dWin_Arr;

    dNrmsd_dWin_Arr = diff(nrmsd_Arr, 1);
    out.dNrmsd_dWin_Cell{iM} = dNrmsd_dWin_Arr;

    out.rmsdProduct_Cell{iM} = rmsd_Arr(1:end-1).*dRmsd_dWin_Arr;
    out.nrmsdProduct_Cell{iM} = nrmsd_Arr(1:end-1).*dNrmsd_dWin_Arr;
    
%     figID = plotphaseLOCAL(errCells{iM},errFirstDerivCells{iM},methods,methIdx,iM);
    
    [~,minIdx] = min(abs([out.rmsdProduct_Cell{iM}]));
    out.optWin_Cell{iM} = winSizes(minIdx);
    out.optSmDat_Cell{iM} = out.smProfiles_Cell{iM}(minIdx,:) ;
%     h{iM} = plotminsLOCAL(errCells{iM}(minIdx),errFirstDerivCells{iM}(minIdx),methods,methIdx,iM);
%     figure(figID)
%     legend(h{:},methods{:})
end

toc
end

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