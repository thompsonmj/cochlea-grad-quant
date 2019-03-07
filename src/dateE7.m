classdef dateE7
properties (Access=private)
    day
    month
    year = yearE7
end

methods
    %% Constructor
    function D = dateE7(d,m,y)
        D.year = yearE7(y);
        D.month = m;
        D.day = d;
    end
end

%% Need a new methods block for static methods. Constructor is not static.
% Static: no dateE7 obj in method arguments list. It's part of the class, but doesn't operate on
% class objects.
methods (Static = true, Access = private)
    function charMonth = m2m(numericalMonth)
        % Converts an inter from 1:12 to month abbrev.
        M = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];
        charMonth = M(numericalMonth,:);
    end
end

end