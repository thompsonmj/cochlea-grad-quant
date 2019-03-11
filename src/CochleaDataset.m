classdef CochleaDataset
% see https://blogs.mathworks.com/loren/2005/12/13/use-dynamic-field-references/
    % Organized like a struct, each field name is a CochleaDataObj, given by a unique random ID.
    % E.g. C = CochleaDataset
    % C.Q8MRJ5TN => holds all the data and metadata from one cochlea organ.
    % C.NFMK324B => holds all the data and metadata from another cochlea organ.
    % Use find() to query for matching values.
    %
    % Each time a new CochleaDataObj is created, it should be passed as an argument to this class,
    % which will append the CochleaDataObj to itself and assign it a unique ID number.
    properties
        C = CochleaDataObj
    end
    methods
        %
    end
end