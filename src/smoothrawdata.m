function smDat = smoothrawdata(RawDat,x)
%SMOOTHRAWDATA Smooth all profiles within a cryosection.
%
% Input:
%   > RawDat: Struct containing raw columnar data from each channel (target)
%   in this cryosection to be aligned.
%       Format: RawDat.Tgt1, RawDat.Tgt2, ...
%       Fields: double, NxM (N = smapled points, M = no. optical sections)
%   > x: Raw circumferencial position data for this cryosection.
%       double, Nx1 (N = sampled points)
% Output:
%   > smDat: Smooth data struct complimentary to RawDat.

%% Setup
T = fieldnames(RawDat);
nTgts = size(T,1);
method = 'loess';

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

% % Organize data into cells for parfor.
% RawDatcell = struct2cell(RawDat);
% smDatcell = cell(nTgts,1);
% meanDatcell = cell(nTgts,1);

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
    
       %%%RawDatcell{iTgt} => RawDat.(T{iTgt})
       profile = RawDat.(T{iTgt})(:,iZ);
%        profile = RawDatcell{iTgt}(:,iZ);
       nPts = numel(profile);
       appendSize = ceil(win/2);
       startPortion = profile( 1 : appendSize ); 
       endPortion = profile( nPts-appendSize : nPts );
       profileAppended = [endPortion; profile; startPortion];
       nPtsAppended = numel(profileAppended);
       
       smProfileAppended = smoothdata(profileAppended,method,win);
       
       smProfileUnappended = smProfileAppended( appendSize+1 : ...
                                                nPtsAppended - (appendSize+1) );
       %%% smDatcell{iTgt} => smDat.(T{iTgt})
       smDat.(T{iTgt})(:,iZ) = [smProfileUnappended];
%        smDatcell{iTgt}(:,iZ) = [smProfileUnappended];
       
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