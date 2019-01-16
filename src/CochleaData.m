classdef CochleaData
    % Video 4 - set and get property methods.
    %% Properties
    properties %%%(SetAccess = private) % properties not 'settable' outside the class's methods.
        % Default property values
        % Each object should the data for one optical slice of one channel.
        CochID          % ID code unique to the organ this data is from.
        SlideID         % ID code of the microscope slide this data is from.
        Age             % Nominal age represented in days post coitum.
        Target          % Molecular target represented by the data.
        MetaData        % Imaging metadata from microscope.
        RawDat          % Raw, untouched data.
        RawLength       % x = L.
        BinnedRawDat    % Raw data binned to a standard size.
        BinnedSmDat     % Smoothed data binned to a standard size.
        %what else???
    end
    methods
        %% Constructor
        
        
        
        %% Individual property set methods
        function C = set.CochID(C,id)
            if ischar(id) && ndims(id)==2 && size(id,1)==1 && size(id,2) == 8 %#ok<ISMAT>
                C.CochID = id;
            else
                error('Invalid cochlea ID');
            end
        end
        function C = set.SlideID(C,slide)
            if true %%%<<<<<<<<<<<<<<<<<<<<<<<<<<
                C.SlideID = slide;
            else
                error('Invalid slide name');
            end
        end
%         function C = set.Age(C,a)
%             options = {'E12.5','E13.5','E14.5','E15.5'};
%             if ismember(a,options)
%                 C.Age = a;
%             else
%                 error('Invalid age.')
%             end
%         end
    end
end