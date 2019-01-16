% For E12.5 cochlea number 1 (SW15 1B).

%% First manually load E12_1 struct containing pSmad and Sox2 data. 

%%
%%%nSections = size(E12_1.raw.psmad,1); % Same for Sox2 and psmad
% 2019-01-09
nSections = size(psmadStruct.raw,2);

% Structures labeled to indicate the order of processing steps (smoothNorm: smoothed then normed).
%%%psmadStruct.smooth = struct;
%%%psmadStruct.smoothNorm = struct;
psmadStruct.smooth = zeros(size(psmadStruct.raw));
psmadStruct.x = {};
psmadStruct.xNorm = {};

% Smoothing parameters.
W = 100; TYPE = 4; ENDS = 1;
for iSection = 1:nSections
    % Establish x coordinates.
    nPts = size(psmadStruct.raw,1);
    psmadStruct.x{iSection,1} = transpose(1:nPts);
% % %     psmadStruct.xNorm{iSection,1} = psmadStruct.x{iSection,1} / max( psmadStruct.x{iSection,1} );
    % Count number of optical slices in this cryosection (same for pSmad and Sox2).
% % %     nSlices = size(psmadStruct.raw.psmad{iSection,1},2);
    
    % Smooth raw data.
    psmadStruct.smooth(:,iSection) = fastsmooth( psmadStruct.raw(:,iSection),W,TYPE,ENDS );
    
% % %     for iSlice = 1:nSlices
% % %         % Smooth raw data.
% % %         psmadStruct.smooth.psmad{iSection,1}(:,iSlice) = ...
% % %         fastsmooth( psmadStruct.raw.psmad{iSection,1}(:,iSlice),W,TYPE,ENDS );
% % %     
% % %         psmadStruct.smooth.sox2{iSection,1}(:,iSlice) = ...
% % %         fastsmooth( psmadStruct.raw.sox2{iSection,1}(:,iSlice),W,TYPE,ENDS );
% % %     
% % %         % Normalize smoothed data.
% % %         psmadStruct.smoothNorm.psmad{iSection,1}(:,iSlice) = ...
% % %             psmadStruct.smooth.psmad{iSection,1}(:,iSlice) / max( psmadStruct.smooth.psmad{iSection,1}(:,iSlice) );
% % %         
% % %         psmadStruct.smoothNorm.sox2{iSection,1}(:,iSlice) = ...
% % %             psmadStruct.smooth.sox2{iSection,1}(:,iSlice) / max( psmadStruct.smooth.sox2{iSection,1}(:,iSlice) );
% % %     end
end
