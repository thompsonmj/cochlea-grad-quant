function fdata = addflagstoselectsections(data)
%ADDFLAGSTOSELECTSECTIONS reads a manually curated list of individual
%sections, each acting as the representative for its respective cochlea
%organ, and adds a flag to the corresponding section in the full dataset.

flagFile = 'flagged-sections.xlsx';
T = readtable(flagFile);

nSections = numel(data);
nFlags = size(T,1);

fdata = data;

count = 0;

for iS = 1:nSections
    for iF = 1:nFlags
        if data(iS).age == T.age(iF) && ...
                data(iS).cochlea_idx == T.cochlea_idx(iF) && ...
                data(iS).section_ab == T.section_ab{iF} && ...
                data(iS).section_idx == T.section_idx(iF)
            fdata(iS).flag = true;
            break
        else
            fdata(iS).flag = false;
        end
    end
end

end