function smDat = smoothrawdata(rawDat, method, win)
%SMOOTHRAWDATA Smooth data without edge effects imposed by 'smoothdata'.
%
% Inputs:
%   > rawDat: Raw columnar profile data to be smoothed.
%   > method: Smoothing method (MATLAB built-in).
%   > win: Window size.
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
% Append copies of the first and final values to the start and end to
% side-step the assumption 'smoothdata' makes that data should start and
% end at zero.
appendSize = ceil(win/2);
startPortion = repmat(rawDat(1), appendSize, 1);
endPortion = repmat(rawDat(end), appendSize, 1);
rawDat_Appended = [startPortion; rawDat; endPortion];
nPts_Appended = numel(rawDat_Appended);

smDat_Appended = smoothdata(rawDat_Appended, method, win);

smDat_Unappended = ... 
    smDat_Appended( appendSize+1 : nPts_Appended - appendSize );
smDat = [smDat_Unappended];

errMsg = 'Data input and output size is not consistent.';
assert( numel(rawDat) == numel(smDat) );
end