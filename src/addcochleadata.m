function addcochleadata(Cobj)
% ADDCOCHLEADATA adds a cochlea data object to the data store and does some
% simple error checking to ensure data is consistent and non-overlapping.
% Input: a cochlea data object creaded using CochleaDataObj
%%%TODO: more checks on contents
    %%%%THIS IS ALL A MESS
    oworkdir = pwd;
    thisfile = mfilename('fullpath')
    [path,~,~] = fileparts(thisfile)
    cd(path)
    dataStoreDir = fullfile('..','..','..','data','quant-profiles')
    dataStoreFile = 'C.mat';
    if isfile(dataStoreFile)
        vars = whos('-file',dataStoreFile);
        if ismember(Cobj.CochleaID, {vars.name})
            error('Namespace collision. Rerun CochleaDataObj on same data to generate a new ID code.');
        end
    end
    
    Cnew = struct;
    id = Cobj.CochleaID;
    Cnew.(id) = Cobj;
    
    f = fullfile(dataStoreDir,dataStoreFile);
    
    load(f,'C')
    
    if isfile(f)
        %%%BELOW IS WRONG. need to index any (id), not just the variable id
        if ismember(id,fieldnames(C))
        if exist('C.(id).SlideID','var') && Cnew.(id).SlideID == C.(id).SlideID
            quest = 'This slide has already been added. Do you want to overwrite?';
            title = 'CAUTION: OVERWRITING DATA';
            answer = questdlg(quest,title);
            switch answer
            case 'Yes'
                C.(id) = Cobj;
            case 'No'
                return
        end
        end
        
    else
        save(f, 'C')
    end
    cd(oworkdir)
end