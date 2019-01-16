function id = genidcode(varargin)

% Inputs
%   1. nChar
%   2. ?
%   idList - to check against for uniqueness (should make separate func) 
%
% PropertyValues
%   'Alpha' {'on','off'} - default on
%   'AllCap' {'on','off'} - default on
%   'MixCap' {'on','off'} - default off
%   'Numeric' {'on','off'} - default on
%   'Symbol' {'on','off'} - default off
%   AllCap and MixCap can only be accepted iff Alpha is 'on'.
%   Throw error if Alpha, Numeric, and Symbol are all 'off'.



switch nargin
    case 0
        disp('Generating default 8-character alphanumeric code.')
        nChar = 8;
        syms = ['A':'Z' '0':'9'];
        idx = randi(numel(syms),[1 nChar]);
        id = syms(idx);        
    case 1 
        nChar = varargin{1};
        
    case 2
        ...
    case 3
        ...
    otherwise
        disp()
end

end