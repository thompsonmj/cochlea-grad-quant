function [rawBProfs, rawAProfs, ...
    meanBProf, meanAProf, ...
    stdBProf, stdAProf, ...
    nBProfs, nAProfs] = organstats(C,target)

% Input 
%   > C = struct or cell array of cochlea data objects.
%   > target: target string
% Output 
%   > meanProf
%   > stdProf
%   > nProfs

if isequal(class(C), 'struct')
    C = struct2cell(C);
end

assert( isequal(target,'pSmad') | ...
        isequal(target,'Sox2') | ...
        isequal(target,'TOPRO3') )

S = fieldnames(C.Dat);
nSecs = numel(S);
nB = 0;
nA = 0;
B = {}; % Section names
A = {}; % Section names
for iSec = 1:nSecs
    if S{iSec}(1) == 'B'
        nB = nB + 1;
        B{nB} = S{iSec};
    elseif S{iSec}(1) == 'A'
        nA = nA + 1;
        A{nB} = S{iSec};
    end
end

basalProfs = zeros(1000,nB);
apicalProfs = zeros(1000,nA);

if nB ~= 0
    for iB = 1:nB
        if isfield(C.Dat.(B{iB}).USR, target)
            basalProfs(:,iB) = C.Dat.(B{iB}).USR.(target).algnDat;
        end
    end
end

if nA ~= 0
    for iA = 1:nA
        if isfield(C.Dat.(A{iA}).USR, target)
            apicalProfs(:,iA) = C.Dat.(A{iA}).USR.(target).algnDat;
        end
    end
end

WEIGHT = 0;

rawBProfs = basalProfs;
rawAProfs = apicalProfs;
meanBProf = mean(basalProfs, 2);
meanAProf = mean(apicalProfs, 2);
stdBProf = std(apicalProfs, WEIGHT, 2);
stdAProf = std(apicalProfs, WEIGHT, 2);
nBProfs = nB;
nAProfs = nA;

end