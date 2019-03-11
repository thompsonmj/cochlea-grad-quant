function xOut = uniformsample(xIn)
% UNIFORMSAMPLE resamples a 1D array to a constant rate. Each column of a
% matrix is treated as a separate channel.

NSAMPLES = 1000;

nSignals = size(xIn,2);

x = (1:numel(xIn(:,1)))';
xp = linspace(x(1), x(end), NSAMPLES);
xOut = zeros(NSAMPLES,nSignals);

for iSignal = 1:nSignals
    xOut(:,iSignal) = interp1(x, xIn(:,iSignal), xp); % Default: linear inerp.
end

end