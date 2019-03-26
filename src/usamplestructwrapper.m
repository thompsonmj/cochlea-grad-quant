function DatUSamp = usamplestructwrapper( DatOSamp, nSamples )
%USAMPLESTRUCTWRAPPER Resamples data held within structs particular to the
%cochlea data object.
%
% Input:
%   > DatOSamp: Struct containing datasets sampled at the raw rate.
%   > nSamples: Desired number of samples for data.
% Output:
%   > DatUSamp: Struct containing uniformly sampled datasets.

F = fieldnames( DatOSamp );
nFlds = numel( F );

for iFld = 1:nFlds
    T = fieldnames( DatOSamp.(F{iFld}) );
    nTgts = numel( T );
    for iTgt = 1:nTgts
        DatUSamp.(F{iFld}).(T{iTgt}) = ...
            uniformsample( DatOSamp.(F{iFld}).(T{iTgt}), nSamples );
    end
end
