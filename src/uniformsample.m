function AOut = uniformsample(AIn,nSamples)
% UNIFORMSAMPLE resamples an array to a constant rate. Each column of a
% matrix is treated as a separate channel.
%
% Inputs:
%   > AIn: array (columnar)
%   > nSamples: number of samples to interpolate from AIn
% Outputs:
%   > AOut: Resampled output containing nSamples points

nCol = size(AIn,2);

x = (1:numel(AIn(:,1)))';
xp = linspace(x(1), x(end), nSamples);
AOut = zeros(nSamples,nCol);

for iCol = 1:nCol
    AOut(:,iCol) = interp1(x, AIn(:,iCol), xp); % Default: linear inerp.
end

end