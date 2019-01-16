% For each image stack:
% Sample and subtract instrument background (scala media)
% Sampled regions propagate thru stack, sampling done at each z-plane
% Sample and subtract tissue background (documented negative expression region)
% Sampled regions propagate thru stack, sampling done at each z-plane
% De-speckle
% Fully automated, run on each z-plane using identical parameters
% Set ROI
% Selection propagates thru stack
% Extract, normalize smooth data
% 
% Repeat 3x for each stack, average results
