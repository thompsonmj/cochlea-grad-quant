function AlDat = alignpeaks( DatToAlgn, template, algnMode, percentile )
%ALIGNPEAKS Align profile data for a cryosection based on a reference profile.
%
% Input:
%   > datToAlgn: Struct containing datasets to align. Each subfield is a
%   struct with subfields for each channel (target).
%       E.g. datToAlgn.Raw.pSmad, datToAlgn.Norm.Sox2
%   > template: Profile on which to base alignment.
%   > algnMode: Strategy for alignment based on percentile.
%       'com': center-of-mass (or centroid) 
%       'mid': midpoint between percentile threshold intersection points.
%   > percentile: Template profile portion above which to base alignment.
%       Must follow 0 < percentile < 1.
%       E.g. percentile = 0.25: threshold set to 75% of max profile value.
% Output:
%   > alDat: Struct containing aligned datToAlign.
%
%%% FUTURE ADDITIONS
%%% varargin to accomodate midpoints between multiple template profiles.

F = fieldnames( DatToAlgn );
nFlds = numel( F );

T = fieldnames( DatToAlgn.(F{1}) );
dataLength = numel( DatToAlgn.(F{1}).(T{1})(:,1) );

ANCHOR = 2/3;
peakAlgnAnchor = round( ANCHOR*dataLength );

% Find the reference point for alignment of the representative profile. 
% Align all channels in this cryosection based on this reference.
switch algnMode
    case 'com'
        [algnIdcs, ~] = ...
            findcom( template, percentile );
        algnIdx = algnIdcs(1);
    case 'mid'
        [algnIdx, ~] = ...
            findmid( template, percentile );
end

shiftIdx = peakAlgnAnchor - algnIdx;

for iFld = 1:nFlds
    T = fieldnames( DatToAlgn.(F{iFld}) );
    nTgts = numel( T );
    for iTgt = 1:nTgts
        AlDat.(F{iFld}).(T{iTgt}) = ...
            circshift( DatToAlgn.(F{iFld}).(T{iTgt}), round(shiftIdx), 1 );
    end
end

end