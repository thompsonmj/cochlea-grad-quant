function [prof8bit, originalDepth] = scaleto8bit(rawProfile)
%SCALETO8BIT Determine bit depth of a raw profile and scale to 8 bit.
%
% Inputs:
%   > rawProfile: 1D column vector containing fluorescent data at bit depth
%   used for acquisition.
% Outputs:
%   > prof8it: Profile scaled to 8 bits (0 to 255).
%   > originalDepth: (optional) Original bit depth detected.
%
% Data is assumed to use approximately its full dynamic range such that
% incorrectly assigning a lower bit depth to profile actually using a
% higher depth is very unlikely.

errMsg = 'Invalid input dimensions.';
assert( size(rawProfile,2) == 1, errMsg );

maxVal = max(rawProfile);
minVal = min(rawProfile);

errMsg = 'Input may not be negative.';
assert( minVal >= 0, errMsg );

max8 = 2^8;
max16 = 2^16;
max32 = 2^32;
max64 = 2^64;

if maxVal < max8
    originalDepth = 8;
    prof8bit = rawProfile;
elseif maxVal >= max8 && maxVal < max16
    originalDepth = 16;
    prof8bit = round( rawProfile/(2^16) );
elseif maxVal >= max16 && maxVal < max32
    originalDepth = 32;
    prof8bit = round( rawProfile/(2^24) );
elseif maxVal >= max32 && maxVal < max64
    originalDepth = 64;
    prof8bit = round( rawProfile/(2^56) );
else
    % Do not accept values outside the range of [0, 2^64);
    error('Input out of range.')
end

end