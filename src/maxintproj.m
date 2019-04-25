function [ maxProj ] = maxintproj( data )
%MAXINTPROJ Return the extended depth of focus maximum intensity projection
%for a set of optical sections.
%
% Input
%   > data: Fluorescent imaging data across several optical sections. 
%       struct of double arrays or double array.
%       If struct, each field is one channel, value for each field is
%       double array.
%       Columnar data, each column is one optical section.
% Output
%   > maxProj: maximum intensity projection of input data.
%       Returns same data type as input.
%       struct of double arrays or double array.
%       Columnnar data, each column is one optical section.

dataClass = class(data);

switch dataClass
    case 'struct'
        % Multi-channel data. Each channel is a fieldname of data, which
        % contains double array values, each column as one optical section.
        T = fieldnames( data );
        nTgts = numel(T);
        maxProj = struct;
        for iTgt = 1:nTgts            
            tgtData = data.(T{iTgt});
            assert( size(tgtData, 1) > size(tgtData, 2) )
            maxData = max(tgtData, [], 2);
            maxProj.(T{iTgt}) = maxData;
        end
    case 'double'
        % Single-channel data. Each column of input array is one optical
        % section.
        assert( size(data, 1) > size(data, 2) )
        maxData = max(data, [], 2);
        maxProj = maxData;
    otherwise
        error( 'Invalid input data type. Must be struct or double.' )
end


end