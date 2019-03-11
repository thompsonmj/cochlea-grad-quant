classdef yearE7
    properties (SetAccess = private)
        Value
        LeapYear
        M
    end
    methods
        %% Constructor
        function Y = yearE7(Yv)
            % Default val of obj w/ name given by output arg var automatically exists at this point.
            if nargin==1
                %                                   integer
                if isscalar(Yv) && isnumeric(Yv) && floor(Yv)==ceil(Yv) && Yv>0
                    Y.Value = Yv;
                    Y.LeapYear = rem(Yv,4)==0 && (rem(Yv,100)~=0 || rem(Yv,400)==0);
                    if Y.LeapYear
                        Y.M = [31 29 31 30 31 30 31 31 30 31 30 31];
                    else
                        Y.M = [31 28 31 30 31 30 31 31 30 31 30 31];
                    end
                elseif isa(Yv,'yearE7') % Input arg Yv already a yearE7 object, simply pass back.
                    Y = Yv;
                else
                    error('Invalid Yv');
                end
            % nargin~=1, default value of object is returned.    
            end
        end
        
        %% Other methods. (all have a yearE7 object in input arg list.
        function N = nDays(Y)
            % Returns number of days in the year.
            N = sum(Y.M);
        end
        
        function C = char(Y)
            % Represents the year as a char.
            C = int2str(Y.Value);
        end
        
        function display(Y)
            % Executes automatically if there is no terminating semicolon and RHS is yearE7 obj.
            disp(['yearE7: ' char(Y)])
        end
        
        function [d,m] = n2dm(Nday,Y)
            % Converts positive integer (day of year) into corresponding day/month of given year.
            cM = cumsum(Y.M);
            m = find(Nday<=cM, 1);
            d = Nday - sum(Y.M(1:m-1));
        end
        %% More further functions
        function Y2 = plus(Y,N)
            Y2 = yearE7(Y.Value+N);
        end
        function F = ge(Y1,Y2)
            F = Y1.Value>=Y2.Value;
        end
        function DB = daysBetween(Y1,Y2)
            DB = 0;
            for i = Y1.Value:Y2.Value - 1
                tmp = yearE7(i);
                DB = DB + nDays(tmp);
            end
        end
        
    end
    
    
end