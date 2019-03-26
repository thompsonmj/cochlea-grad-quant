function [ comIdcs, threshIdcs ] = findcom( profile, percentile )
%FIND1DCOM finds the x-index for the center-of-mass (centroid) of the top
% given percentile of the data.
%
% Inputs:
%   profile: 1D array 
%   percentile: percentage threshold of max over which to apply
%   center-of-mass (COM). 
%       If percentile == 0, all data is considered in calculation.
%       If percentile => 1, at minimum a single value is used (max value). 
% Outputs:
%   comIdcs: global x and y cooridnates of the thresholded COM
%       1x2, double
%   threshIdcs: global x indices for the threshold
%       1x2, double

% Validate input data.
assert(isrow(profile) || iscolumn(profile), ...
    'Input array must be 1D.')
assert(percentile > 0 && percentile < 1, ...
    'Input percentile must be between [0,1).')

if isrow(profile)
    profile = profile';
end

[maxVal,~] = max(profile);
threshVal = (1 - percentile)*maxVal;

% Check if the profile contains a single region above the specified
% threshold. If not, smoothing or percentile may need to be altered.
if max(diff(find(profile > threshVal))) > 1
    x = [1:numel(profile)];
    figure
    plot(x,threshVal,'.','Color','k')
    hold on, plot(x,profile), hold off;
    answer = questdlg(['WARNING: Profile above specified threshold is' ...
        'discontinuous. Proceed with current settings?'], ...
        'Discontinuous profile.', ...
        'Proceed','Quit','Quit');
    switch answer
        case 'Proceed'
            warning('Calculating center-of-mass using discontinuous profile.')
        case 'Quit'
            error('Choose a new threshold percentile or adjust smoothing.')
    end
end

xRegion = find(profile > threshVal);
yRegion = profile(profile > threshVal) - threshVal;

A = sum(yRegion);

xBar = (1/A)*sum(xRegion.*yRegion);
yBar = (1/A)*sum(0.5*yRegion.^2) + threshVal;

comIdcs = [xBar, yBar];

threshIdcs = [xRegion(1), xRegion(end)];

end