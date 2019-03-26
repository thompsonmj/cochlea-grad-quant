function [alRawDat,alSmDat] = alignpeaks(RawDat,x,mode,PERCENTILE)
% ALIGNPEAKS 
%
% Input:
%   RawDat: struct containing raw data from each channel to be aligned.
%   x: 1D raw radial position data.
%   mode: 

%%%CONSIDER>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Assuming identical image resolution of inputs, a constant smoothing
% window should be OK. For images of varying resolution, size of smoothing
% window will cover more or less physical space and result in different
% degrees of smoothness. For robustness, This should detect image
% resolution and alter window accordingly.
% E.g. One raw image is 512x512 and another is 1024x1024. The smoothing
% window for the first should be half the size of the second.
% The resolution could be inferred by the distance between raw RadPsn data
% points.
% 1024x1024 resolution: average diff = 0.3108
% 512x512 resolution: average diff = 0.6239
% Very consistant, std for each is O(1e-4)

% IMPORTANT
% Windows at tails do now see the opposite tail. Need to append to get
% a signal that can be shifted without discontinuities.
%%%CONSIDER<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

%%%Don't use cochlea 17 for troubleshooting.
alSmDat = struct;

T = fieldnames( RawDat );
nTgts = size(T,1);

% Smooth raw data. Append tails with data from opposite tail so the moving
% window sees a semi-continuous signal.
% Adequate window size determined by eye.
if mean(diff(x)) > 0.3 && mean(diff(x)) < 0.4   
    % Corresponds to 1024 x 1024 image resolution.
    win = 10;
elseif mean(diff(x)) > 0.6 && mean(diff(x)) < 0.7
    % Corresponds to 512 x 512 image resolution.
    win = 300;
else 
    error('Invalid resolution.');
end
        
    
for iTgt = 1:nTgts

    profileSet = RawDat.(T{iTgt});
    
    %%% Normalize optical slices within a cryosection and rescale to
    %%% original scale.
    disp(T{iTgt})
    pause(2)
    figure,hold on
    plot(profileSet,'LineStyle',':')
    
    mnProfile = mean(profileSet,2);
%     profileSetAppended = [];
    smProfileSetUnappended = [];
    nZ = size(profileSet,2);
    % Smooth first, then normalize.
    for iZ = 1:nZ
    
       profile = RawDat.(T{iTgt})(:,iZ);
       nPts = numel(profile);
%        appSize = floor(nPts*0.3); % 0.3 arbitrary. Must be > win/2.
       appSize = ceil(win/2);
       startQuartile = profile( 1 : appSize ); 
       endQuartile = profile( nPts-appSize : nPts );
       profileAppended = [endQuartile; profile; startQuartile];
       nPtsAppended = numel(profileAppended);
       
       method = 'rloess';
       smProfileAppended = smoothdata(profileAppended,method);
       smProfileUnappended = smProfileAppended( appSize+1 : ...
                                                nPtsAppended - (appSize+1) );
       
%        profileUnappended = profileAppended( appSize+1 : ...
%                                             nPtsAppended - (appSize+1) );
       
%        profileSetAppended = [profileSetAppended,profileAppended];
       smProfileSetUnappended = [smProfileSetUnappended,smProfileUnappended];
       
    end
%     mnProfileAppended = mean(profileSetAppended,2);
%     mnProfileUnappended = mnProfileAppended( appSize+1 : ...
%                                              nPtsAppended - (appSize+1) );
%     [smMnProfileAppended,win] = smoothdata(mnProfileAppended,'sgolay',win,'Degree',2);
%     smMnProfileUnappended = smMnProfileAppended( appSize+1 : nPtsAppended - (appSize+1) );
    
%     plot(smMnProfileUnappended,'LineWidth',4,'Color','r')
%     plot(smMnSignalUnAppended600,'LineStyle','--','Color','k')

%     normOutput = normdat(smProfileSetUnappended)

    plot(smProfileSetUnappended,'b')
    plot(mean(smProfileSetUnappended,2),'LineWidth',3,'Color','b')
%     plot(mnProfileUnappended,'LineStyle',':','Color','k')
    title([T{iTgt},' - ',method])
%     smSignalmovmean = smoothdata(avSignal, 'movmean');
%     figure;
%     grid on
%     hold on
%     plot(avSignal,'Color','k');
%     plot(signalSet,'LineStyle',':','Color','k');
%     plot(smSignalsgolay,'LineWidth',3,'Color','b')
%     plot(smSignalmovmean,'LineWidth',3,'Color','m')
%     for iZ = 1:nZ
%        signal = RawDat.(T{iTgt})(:,iZ);
%        nPts = numel(signal);
%        quart = floor(nPts*0.25);
%        startQuartile = signal( 1 : quart ); 
%        endQuartile = signal( nPts-quart : nPts );
%        signalAppended = [startQuartile; signal; endQuartile];
%        smSignalAppended = smoothdata(signalAppended, ...
%             'sgolay', ...
%             'SmoothingFactor', 0.2);
%        smSignal = smSignalAppended( quart+1 : nPts-(quart+1) );
%        smSignalsgolayz = smoothdata(signal, 'sgolay');%,'SmoothingFactor',0.2);
%        smSignalmovmeanz = smoothdata(signal,'movmean');
%        
%        plot(smSignalsgolayz,'LineWidth',2,'Color','b','LineStyle','--');
%        plot(smSignalmovmeanz, 'LineWidth',2,'Color','m','LineStyle','--');
% 
%        
%     end
%     alSmDat.(T{iTgt}) = smSignal; % Not yet aligned.

end

% Align smoothed data based on the method specified in 'mode'.
switch mode
    case 'pSmad'
        msg = 'pSmad data missing. Cannot use pSmad alignment.';
        assert(isfield(RawDat,mode),msg);
        idx = findcentroidLOCAL( RawDat.(mode) );
        ANCHOR = 2/3;
        % Temporarily smooth data to accurately assess peak regions.
        %thresh = ()*;
            
    case 'Sox2'
        msg = 'Sox2 data missing. Cannot use Sox2 alignment.';
        assert(isfield(RawDat,mode),msg);
        idx = findcentroidLOCAL( RawDat.(mode) );
        ANCHOR = 1/3;
        
    case 'mid'
        msg = 'Sox2 or pSmad data missing. Cannot use mid alignment.';
        assert(isfield(RawDat,'pSmad') && isfield(RawDat,'Sox2'),msg);
        idx1 = findcentroidLOCAL( RawDat.Sox2 );
        idx2 = findcentroidLOCAL( RawDat.pSmad );
        idx = (idx1 + idx2)/2;
        
        ANCHOR = 1/2;
        
end

%%% use circshift to shift all data based on idx.

    function idx = findcentroidLOCAL(tgt,PERCENTILE)
        %...
    
    end

end