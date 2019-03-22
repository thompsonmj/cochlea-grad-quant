function id = genidcode(varargin)
%GENIDCODE creates a random, all-caps, alphanumeric ID that always begins
% with a letter. Defaults to 8-characters. Providing a numeric argument
% specifies a custom lenth.

switch nargin
    case 0
        disp('Generating default 8-character alphanumeric code.')
        nChar = 8;
        id = genid(nChar);
    case 1 
        in = varargin{1};
        if isnumeric(in)
            nChar = round( varargin{1} );
            id = genid(nChar);
        else
            error('Invalid input type.')
        end
    otherwise
        error('Invalid number of arguments.')
end

    function id = genid(nChar)
        charset1 = ['A':'Z'];
        charset = ['A':'Z' '0':'9'];
        idx = randi(numel(charset1));
        idx = horzcat( idx, randi(numel(charset),[1 nChar-1]) );
        id = charset(idx);  
    end

assert(isvarname(id),'Invalid variable name generated.');

end