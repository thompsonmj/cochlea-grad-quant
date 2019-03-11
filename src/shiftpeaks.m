load('psmad.mat')
data = psmadStruct.smooth;

nSlices = size(data,2);
nVals = size(data{1,1},2);

maxIndices = zeros(nSlices,1);
offsets = zeros(nSlices,1);

for iSlice = 1:nSlices
    [val, maxIndices(iSlice,1)] = max(data{1,iSlice});
end

avgInd = mean(maxIndices);
disp(['avgInd = ', num2str(avgInd)])

for iSlice = 1:nSlices
    offsets(iSlice,1) = -( maxIndices(iSlice,1) - avgInd );
end





