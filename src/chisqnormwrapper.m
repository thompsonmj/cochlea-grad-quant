function NormDatChiSq = chisqnormwrapper(SmDat)
%CHISQNORMWRAPPER description 
%
% Input:
%   > smDat: Struct containing smoothed columnar data from each channel
%   (target) in this cryosection to be normalized.
% Output:
%   > normDatChiSq: Struct containing normalized data complimentary to
%   input.

%% Setup
% [nPts, nProfiles] = size(profileSet);
% profileRawMatrix = zeros(nPts, nProfiles);
T = fieldnames(SmDat);
nTgts = size(T,1);
% Organize data into cells for parfor to slice.
smDatcell = struct2cell(SmDat);
normOutcell = cell(nTgts,1);
%% Execute normalization for each channel (target) in parallel.
for iTgt = 1:nTgts     
%     profileSet = smDatcell{iTgt};
%     nZ = size(profileSet,2);
    % Normalize smoothed optical sections on this channel.
    normOutcell{iTgt} = normdat( smDatcell{iTgt} );    
end

% Parse data into structures by target as fieldnames.
for iTgt = 1:nTgts
    NormDatChiSq.(T{iTgt}) = normOutcell{iTgt};
end

end