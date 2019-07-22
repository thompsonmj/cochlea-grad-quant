function smDat = smoothrawdata(rawDat,method,win)
%SMOOTHRAWDATA Smooth all profiles within a cryosection.
%
% Inputs:
%   > rawDat: Raw columnar profile data to be smoothed.
%   > method: Smoothing method (MATLAB built-in).
% Output:
%   > smDat: Smooth data complimentary to rawDat.

%% Input validation.
dims = size(rawDat);
assert( dims(1) > 1 && dims(2) == 1 ); % Must be column matrix.
assert( isequal(method, 'loess') | ...
        isequal(method, 'sgolay') | ...
        isequal(method, 'movmean') | ...
        isequal(method, 'movmedian') | ...
        isequal(method, 'gaussian') | ...
        isequal(method, 'lowess') | ...
        isequal(method, 'rloess') | ...
        isequal(method, 'rlowess') )

%% Execute smoothing.
appendSize = ceil(win/2);
startPortion = repmat(rawDat(1),appendSize,1);
endPortion = repmat(rawDat(end),appendSize,1);
rawDatAppended = [startPortion; rawDat; endPortion];
nPtsAppended = numel(rawDatAppended);

smDatAppended = smoothdata(rawDatAppended,method,win);

smDatUnappended = ... 
    smDatAppended( appendSize+1 : nPtsAppended - (appendSize+1) );
smDat = [smDatUnappended];

end