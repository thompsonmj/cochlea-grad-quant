classdef employee
    properties
        Name = 'Name'
        Category = 'Category'
        IDNumber = 'IDN'
    end
    methods
        % Property-set methods to constrain property assignments.
        function E = set.Name(E,name)
            % Name must be char, 2-dimensional, and is a row vector.
            if ischar(name) && ndims(name)==2 && size(name,1)==1
                E.Name = name;
            else
                error('Invalid name');
            end
        end
        
        function E = set.Category(E,newCat)
            possCat = {'Trainee','Intern','Part-Time','Salary','Manager','CEO'};
            switch newCat
                case possCat
                    E.Category = newCat;
                otherwise
                    error('Invalid Category');
            end
        end
        
        function E = set.IDNumber(E,idn)
            if isnumeric(idn) && isscalar(idn) && ceil(idn)==floor(idn) && idn>0
                E.IDNumber = idn;
            else
                error('Invalid IDNumber');
            end       
        end

        
    end
end