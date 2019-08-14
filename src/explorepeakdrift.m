% Purpose
% > Characterize stability of peak locations across basal->apical sections
% for many cochleae.
% 
% 1. Use one optimally smoothed profile per cryosection.
% 2. Normalize profile to its own min/max.
% 3. Normalize along x-dimension.
% 4. Plot all profiles from a cochlea on one axis.
% 5. Encode relative basal->apical location with color.

% Population-scale analysis
% > Determine peak location using COM function.
% > Determine average % movement per inter-section distance (15 µm usually)
% > 
%% 
sections = fields(RawDat);
nSections = numel(sections);
figure
for iS = 1:nSections
    targets = fields(RawDat.(sections{iS}));
    if targets{1}=="Bmp4_mRNA"
        d = RawDat.(sections{iS}).(targets{1}).data;
        x = RawDat.(sections{iS}).(targets{1}).xPsn;
        x = x/max(x);
        plot(x,d)
        hold on
    end
end