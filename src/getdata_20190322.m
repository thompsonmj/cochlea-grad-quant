nC = numel(C);
psmadTot = zeros(1000,1);
sox2Tot = zeros(1000,1);
count = 0;
for iC = 1:nC
    nS = numel(fieldnames(C{iC}.Dat));
    sFlds = fieldnames(C{iC}.Dat);
    for iS = 1:nS
        count = count+1;
        psmadTot(:,count) = C{iC}.Dat.(sFlds{iS}).USR.pSmad.mn;
        sox2Tot(:,count) = C{iC}.Dat.(sFlds{iS}).USR.Sox2.mn;
    end
end