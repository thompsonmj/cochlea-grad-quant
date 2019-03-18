function [alRawDat,alSmDat] = alignpeaks(RawDat,x,mode,percentile)
% ALIGNPEAKS 
%%% Add 'method' input to specify centroid/midrange/abspeak, etc???
%
% Input:
%   RawDat: struct containing raw columnar data from each channel to be aligned.
%       Rows: position indices, Columns: optical sections
%       Format: RawDat.Tgt1, RawDat.Tgt2, ...
%   x: 1D raw circumferencial position data.
%   mode: 

%%%CONSIDER>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% Using multiple optical sections (>=3) per cryosection to get a less noisy estimate of the true
% profiles. 
% Issues: 
%   1. Intensities decrease above/below mid optical plane.
%   Possible causes:
%       a. out-of-plane fluorescence
%   Possibile methods to address this problem:
%       a. Normalize optical sections within a cryosection and rescale to original scale.
%           a1. Rescale to mean
%           a2. Rescale to max
%       b. Use optical theory (e.g. PSF) to scale profiles
%   2. Sox2 stain behaves differently than pSmad/Topro3 in some cases. I.e., signal is much lower at
%   lower optical sections than higher ones
%
% NOT NORMALIZING OPTICAL SECTIONS WITHIN A SINGLE CRYOSECTION
%   
%%%CONSIDER<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

%%%Don't use cochlea 17 for troubleshooting.
alSmDat = struct;

T = fieldnames(RawDat);
nTgts = size(T,1);

%% Smooth raw data. Append tails with data from opposite tail so windows see continuous signals.

method = 'sgolay';

% Adjust smoothing window size based on image resolution.
% Adequate window size determined by eye.
if mean(diff(x)) > 0.3 && mean(diff(x)) < 0.4   
    % Corresponds to 1024 x 1024 image resolution.
    win = 500;
elseif mean(diff(x)) > 0.6 && mean(diff(x)) < 0.7
    % Corresponds to 512 x 512 image resolution.
    win = 250;
else 
    error('Invalid resolution.');
end


for iTgt = 1:nTgts

    smDat.(T{iTgt}) = struct([]);
    meanDat.(T{iTgt}) = struct([]);
    
end

for iTgt = 1:nTgts

    profileSet = RawDat.(T{iTgt});
    
    nZ = size(profileSet,2);
    
    smDat.(T{iTgt}) = zeros(size(profileSet));
    
    % Smooth, average, then align.
    for iZ = 1:nZ
    
       profile = RawDat.(T{iTgt})(:,iZ);
       nPts = numel(profile);
       appendSize = ceil(win/2);
       startPortion = profile( 1 : appendSize ); 
       endPortion = profile( nPts-appendSize : nPts );
       profileAppended = [endPortion; profile; startPortion];
       nPtsAppended = numel(profileAppended);
       
       smProfileAppended = smoothdata(profileAppended,method,win);
       
       smProfileUnappended = smProfileAppended( appendSize+1 : ...
                                                nPtsAppended - (appendSize+1) );
              
       smDat.(T{iTgt})(:,iZ) = [smProfileUnappended];
       
    end
    
    % Normalize smoothed optical sections on this channel.
    %%% Integral normalization is possibly the most appropriate: 
    %%% "equal integrals, which imposes the implicit assumption on
    %%% the normalized data that each specimen contains the same number of the 
    %%% molecular species assayed"
    %%%
    %%% David (2019-03-18): more defensible to use a single normalization approach
    %%% throughout a paper. ChiSq for optical sections in a cryosectoin aligns more with the hypothesis that the
    %%% signal observed at each position is distorted by a function of
    %%% experimental (reagent penetrance, etc) and optical (out of plane fluorescence, etc.)
    %%% systematic distortoins from the true value.
    normOut = normdat( smDat.(T{iTgt}) );
    
    meanDat.(T{iTgt}) = mean(normOut.ChiSq,2);
    
    % Rescale normalized profiles to original scale.
    

end

% Align smoothed data based on the method specified in 'mode'.
switch mode
    case 'pSmad'
        msg = 'pSmad data missing. Cannot use pSmad alignment.';
        assert(isfield(RawDat,mode),msg);
        ANCHOR = 2/3;
        peakAlignAnchor = round( ANCHOR*numel(x) );
        nZ = size(RawDat.pSmad,2);
        comIdcsArray = cell(nZ,1);
        threshIdcsArray = cell(nZ,1);
        % Find the center-of-mass of each smoothed optical section. Align
        % all channels at that optical section based on results.
        for iZ = 1:nZ
            profile = meanDat.pSmad;
            [comIdcsArray{iZ}, threshIdcsArray{iZ}] = ...
                findcom(profile,percentile);
            shiftIdx = peakAlignAnchor - comIdcsArray{iZ}(1); % x-coordinate for COM
            
            for iTgt = 1:nTgts
                
                %%% Add a check to make sure z values match up (some Sox2
                %%% data doesn't contain all z-sections.
                
                alRawDat.(T{iTgt})(:,iZ) = ...
                    circshift( RawDat.(T{iTgt})(:,iZ), round(shiftIdx), 1 );
                alSmDat.(T{iTgt})(:,iZ) = ...
                    circshift( smDat.(T{iTgt})(:,iZ), round(shiftIdx), 1 );
                
            end
            
        end

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



%alRawDat = 1;
end