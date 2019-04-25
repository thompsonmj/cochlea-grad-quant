% See Positional information, in bits (Dubuis et al, 2013) Fig. 1 C.
figure
smDatL = snorm2;

nX = size(smDatL,1);
nZ = size(smDatL,2);

val = zeros(nX*nZ,1);
delta = zeros(nX*nZ,1);

idx = 0;
for iX = 1:nX
    meanVal = mean(smDatL(iX,:));
    stdVal = std(smDatL(iX,:));
    for iZ = 1:nZ
        idx = idx + 1;
        delta(idx) = (smDatL(iX,iZ) - meanVal)/stdVal;
    end
end

maxDelta = max(abs(delta));

hist = histogram(delta, ...
    'Normalization','probability', ...
    'FaceColor','b', ...
    'EdgeColor','none' ...
        );
title('Sox2')
xlabel('\Delta')
ylabel('p(\Delta)')
xlim([maxDelta*-1, maxDelta])

% hist.Color property doesn't exist.
% hist.Color = 'w'
