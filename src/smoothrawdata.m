function smDat = smoothrawdata(RawDat,x,method,varargin)
%SMOOTHRAWDATA Smooth all profiles within a cryosection.
%
% Input:
%   > RawDat: raw columnar profile data to be smoothed.
%       Either a struct with target fieldnames or a single array.
%   > RawDat: Struct containing raw columnar data from each channel (target)
%   in this cryosection to be aligned.
%       Format: RawDat.Tgt1, RawDat.Tgt2, ...
%       Fields: double, NxM (N = smapled points, M = no. optical sections)
%   > x: Raw circumferencial position data for this cryosection. Used for
%   setting window size.
%       double, Nx1 (N = sampled points)
%   > method: smoothing method.
%       'loess' or 'sgolay'
% Output:
%   > smDat: Smooth data struct complimentary to RawDat.

%% Input validation.
% assert( isstruct(RawDat) |  )
assert( isequal(method, 'loess') | ...
        isequal(method, 'sgolay') | ...
        isequal(method, 'movmean') | ...
        isequal(method, 'movmedian') | ...
        isequal(method, 'gaussian') | ...
        isequal(method, 'lowess') | ...
        isequal(method, 'rloess') | ...
        isequal(method, 'rlowess') )

%% Setup
T = fieldnames(RawDat);
nTgts = size(T,1);

% Adjust smoothing window size based on image resolution.
% Adequate window size determined by eye.
switch numel(varargin)
    case 0
        if mean(diff(x)) > 0.302 && mean(diff(x)) < 0.322   
            % Corresponds to 1024 x 1024 image resolution (0.312).
            win = 160;
        elseif mean(diff(x)) > 0.614 && mean(diff(x)) < 0.634
            % Corresponds to 512 x 512 image resolution (0.624).
            win = 80;
        else 
            warning('Unexpected resolution. Scaling window size accordingly');
            d = mean(diff(x));
            win = round( d*(-801.2821) + 750 ); % Derived from above settings.
        end
    case 1
        win = varargin{1};
end


%% Execute smoothing on each optical section.
for iTgt = 1:nTgts
    
    %%%RawDatcell{iTgt} => RawDat.(T{iTgt})
    profileSet = RawDat.(T{iTgt});
%     profileSet = RawDatcell{iTgt};
    
    nZ = size(profileSet,2);
    
    %%% smDatcell{iTgt} => smDat.(T{iTgt})
    smDat.(T{iTgt}) = zeros(size(profileSet));
%     smDatcell{iTgt} = zeros(size(profileSet));
    
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
    
%     % Normalize smoothed optical sections on this channel.
%     normOut = normdat( smDatcell{iTgt} );
%     
%     %%%meanDatCell{iTgt} => meanDat.(T.{iTgt})
%     meanDatcell{iTgt} = mean(normOut.ChiSq,2);

end

% % Parse data into structures by target as fieldnames.
% for iTgt = 1:nTgts
%     smDat.(T{iTgt}) = smDatcell{iTgt};
%     meanDat.(T{iTgt}) = meanDatcell{iTgt};
% end

end