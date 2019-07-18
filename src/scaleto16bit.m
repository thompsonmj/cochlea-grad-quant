function [prof16bit, originalDepth] = scaleto16bit(rawProfile)
%SCALETO16BIT Determine bit depth of a raw profile and scale to 16 bit.
%
% Inputs:
%   > rawProfile: 1D column vector containing fluorescent data at bit depth
%   used for acquisition.
% Outputs:
%   > prof16bit: Profile scaled to 16 bits (0 to 65535).
%   > originalDepth: (optional) Original detected bit depth.
%
% Input data is assumed to use approximately its full dynamic range such
% that incorrectly assigning a lower bit depth to a profile actually using
% a higher depth is unlikely.

errMsg = 'Invalid input dimensions.';
assert( size(rawProfile,2) == 1, errMsg );

maxVal = max(rawProfile);
minVal = min(rawProfile);

errMsg = 'Input may not be negative.';
assert( minVal >= 0, errMsg );

% The Zeiss LSM-800 max depth is 16 bit. Enable up to 32.
max8 = 2^8;
max16 = 2^16;
max32 = 2^32;

if maxVal < max8
    originalDepth = 8;
    prof16bit = round( rawProfile*2^8 );
elseif maxVal >= max8 && maxVal < max16
    originalDepth = 16;
    prof16bit = rawProfile;
elseif maxVal >= max16 && maxVal < max32
    originalDepth = 32;
    prof16bit = round( rawProfile/(2^16) );
else
    % Do not accept values outside the range of [0, 2^32);
    error('Input out of range.')
end

end