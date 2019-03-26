% For E12.5 cochlea number 1 (SW15 1B).

%% First manually load E12_1 struct containing pSmad and Sox2 data. 

%%
nSections = size(E12_1.raw.psmad,1); % Same for Sox2 and psmad

% Structures labeled to indicate the order of processing steps (smoothNorm: smoothed then normed).
E12_1.smooth = struct;
E12_1.smoothNorm = struct;
E12_1.x = {};
E12_1.xNorm = {};



% Smoothing parameters.
W = 100; TYPE = 4; ENDS = 1;
for iSection = 1:nSections
    % Establish x coordinates.
    nValues = size(E12_1.raw.psmad{iSection,1},1);
    E12_1.x{iSection,1} = transpose(1:nValues);
    E12_1.xNorm{iSection,1} = E12_1.x{iSection,1} / max( E12_1.x{iSection,1} );
    % Count number of optical slices in this cryosection (same for pSmad and Sox2).
    nSlices = size(E12_1.raw.psmad{iSection,1},2);
    for iSlice = 1:nSlices
        % Smooth raw data.
        E12_1.smooth.psmad{iSection,1}(:,iSlice) = ...
        fastsmooth( E12_1.raw.psmad{iSection,1}(:,iSlice),W,TYPE,ENDS );
    
        E12_1.smooth.sox2{iSection,1}(:,iSlice) = ...
        fastsmooth( E12_1.raw.sox2{iSection,1}(:,iSlice),W,TYPE,ENDS );
    
        % Normalize smoothed data.
        E12_1.smoothNorm.psmad{iSection,1}(:,iSlice) = ...
            E12_1.smooth.psmad{iSection,1}(:,iSlice) / max( E12_1.smooth.psmad{iSection,1}(:,iSlice) );
        
        E12_1.smoothNorm.sox2{iSection,1}(:,iSlice) = ...
            E12_1.smooth.sox2{iSection,1}(:,iSlice) / max( E12_1.smooth.sox2{iSection,1}(:,iSlice) );
    end
end
