function consolidaterawdata( varargin )
%CONSOLIDATERAWDATA 

FullRawDat = struct;

nargin = numel(varargin);
switch nargin
    case 0
        msg = 'Select age level directory holding samples to include.';
        workdir = uigetdir(pwd,msg);
    case 1
        workdir = varargin{1};
end

contents = dir(workdir);
nElements = numel(contents);

for iElement = 3:nElements % Start at 3. Elements 1 and 2 are '.' and '..'.
    folder = contents(iElement).folder;
    name = contents(iElement).name;
    [s,e] = regexp(name,'^\d+(?=_)'); % Digits at start of name before '_'.
    if contents(iElement).isdir && ...
            ~isempty(s) && ...
            ~isempty(e)
        % Element is a directory with digits at start of name before '_'.
        quantProfDir = findquantprofdirLOCAL( fullfile(folder,name) );
    else
        % Element is not a folder or is not a cochlea sample.
        continue
    end
    cochleaID = ['C',name(s:e)];
    
    try
        load(fullfile(quantProfDir,'RawDat_16-bit.mat'),'RawDat');
        FullRawDat.(cochleaID) = RawDat;
        clear 'RawDat'
    catch
        msg = [fullfile(quantProfDir,'RawDat_16-bit.mat'),' not found'];
        warning(msg)
    end
    

end

save(fullfile(workdir,'FullRawDat.mat'),'FullRawDat')

end

function finalDir = findquantprofdirLOCAL(thisDir)
contents = dir(thisDir);
nElements = numel(contents);
validDirCounter = 0;
for iElement = 3:nElements
    firstChar = contents(iElement).name(1);
    if contents(iElement).isdir && ...
            firstChar ~= '_' && ...
            firstChar ~= 'x'
        % Element is a valid directory.
        folder = contents(iElement).folder;
        name = contents(iElement).name;
        thisLocation = fullfile(folder,name);
        if contents(iElement).name == "quant-prof"
            % Element is the 'quant-prof' directory.
            finalDir = thisLocation;
            return
        else
            % Element is not the 'quant-prof' directory, but it is the
            % right place to go down to the next level.
            validDirCounter = validDirCounter + 1;
            nextDir = thisLocation;
        end
    else
        % Element is not a valid directory.
        continue
    end
end

errMsg = ['Too many valid directories to search here: ',thisDir];
assert(validDirCounter == 1,errMsg)

finalDir = findquantprofdirLOCAL( nextDir );
    
end