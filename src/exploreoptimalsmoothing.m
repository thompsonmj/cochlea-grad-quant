f = 'FullRawDat.mat';
p = '/depot/dumulis/cochlea/data/img/sw/wt/E12.5';

load(fullfile(p,f))

cochleae = fields(FullRawDat);
% cochleae = {'C14'};% Fort testing
nCochleae = numel(cochleae);

iCounter = 0;

targets = {'pSmad','Sox2','Jag1','TOPRO3','Bmp4_mRNA','Id2_mRNA'};
nTargets = numel(targets);

out = {};
targs = {};

for iC = 1:nCochleae
    sections = fields(FullRawDat.(cochleae{iC}));
    nSections = numel(sections);
    for iS = 1:nSections
        if ismember('A',sections{iS})
            continue % Skip apical sections.
        end
        currentTargets = fields(FullRawDat.(cochleae{iC}).(sections{iS}));
        for iT = 1:nTargets
            if ismember(targets{iT},currentTargets)
                disp([cochleae{iC},'.',sections{iS},'.',targets{iT},' ',num2str(round(iC/nCochleae*100)),'%'])
                iCounter = iCounter + 1;
                profile = FullRawDat.(cochleae{iC}).(sections{iS}).(targets{iT});
                xPsn = profile.xPsn;
                rawDat = profile.data;
                winStep = 2;
                outStruct = optimalsmoothing(rawDat,xPsn,winStep);
                outStruct.raw = rawDat;
                outStruct.targ = targets{iT};
                outStruct.Cochlea = cochleae{iC};
                outStruct.Section = sections{iS};
                outStruct.xPsn = xPsn;
                out{iCounter} = outStruct;
            end
        end
    end
end

save('SmOpt.mat','-v7.3')