% 
% if isfile('F:\projects\cochlea\apps\cochlea-grad-quant.git\src\Projection-Inputs.mat')
%     load('F:\projects\cochlea\apps\cochlea-grad-quant.git\src\Projection-Inputs.mat')
% end

oworkdir = pwd;

if pwd ~= "F:\projects\cochlea\data\img\sw\wt\E12.5"
    cd(fullfile('..','..','..','data','img','sw','wt','E12.5'))
end

d = uigetdir;   

d = fullfile(d,'tif-orient','sep-ch','mip','despeckle','_dat_');

%% Update for each folder
% >>> C33: error on B2
% sox2, psmad
% idx = [1,3,4];
% cochleaID = 'C33B';

% C32: ALL WORKING
% sox2, psmad
% idx = [1,2,3,4,5,7,8];
% cochleaID = 'C32B';

% >>> C31: pts.roi incomplete
% sox2, psmad
% idx = [1,2,3,4,5,6,7,8];
% cochleaID = 'C31B';

% C30: pts.roi incomplete
% sox2, psmad
% idx = [4,5,6,7,8,9,10,11,12,13,14];
% cochleaID = 'C30B';

% >>> C29: no Sox2 data for B1, throwing code off 
% sox2, psmad
% idx = [1,7];
% cochleaID = 'C29B';

% C28: pts.roi incomplete
% sox2, psmad
idx = [5,6,7,9,11];
cochleaID = 'C28B';

% C27: pts.roi incomplete
% sox2, psmad
% idx = [4,6,7,8];
% cochleaID = 'C27B';

% no cochlea numbered 24-26

% C23: ALL WORKING
% sox2, psmad
% idx = [1,2,3,4];
% cochleaID = 'C23B';

% C22: ALL WORKING
% sox2, psmad
% idx = [1,2,3,4];
% cochleaID = 'C22B';

% C21: pts.roi incomplete
% sox2, psmad
% idx = [1,2,3];
% cochleaID = 'C23B';

% C20: pts.roi incomplete
% sox2, psmad
% idx = [1,5,7,11,13];
% cochleaID = 'C20B';

% no cochlea numbered 18-19

% C17: pts.roi incomplete
% sox2, psmad
% idx = [1,2,3,4,5,6,7,8,9];
% cochleaID = 'C17B';

%%%%%%%%%%%%%%%%%%%%%%% C16: pts.roi incomplete
% sox2, psmad
% idx = [4,5,6,7,8,9,10];
% cochleaID = 'C16B';

% no cochlea numbered 15

% C14: pts.roi incomplete
% sox2, psmad
% idx = [1,2,3,4];
% cochleaID = 'C14B';

% no cochlea numbered 10-13

% C9: pts.roi incomplete
% sox2, psmad
% idx = [1,2,6];
% cochleaID = 'C9B';

% no cochlea numbered 6-8

% C5: pts.roi incomplete
% sox2, psmad
% idx = [1,2,3];
% cochleaID = 'C5B';

% C4: pts.roi incomplete
% sox2, psmad
% idx = [3,5,6];
% cochleaID = 'C4B';

% no cochlea numbered 3

% C2: pts.roi incomplete
% sox2, psmad
% idx = [11,12];
% cochleaID = 'C2B';

%% Main script
nS = numel(idx);

% Build input struct for this cochlea
for iS = 1:nS
    inFile1 = fullfile(d,['B',num2str(idx(iS)),'_pts.roi']);
    inFile2 = fullfile(d,['B',num2str(idx(iS)),'_pse.roi']);
    inFile3 = fullfile(d,['B',num2str(idx(iS)),'_ch3-psmad_mip.tif']);
    inFile4 = fullfile(d,['B',num2str(idx(iS)),'_ch2-sox2_mip.tif']);
    inFile5 = fullfile(d,['B',num2str(idx(iS)),'_ch1-topro3_mip.tif']);
    
    if isfile(inFile1)
        inputs(1).([cochleaID,num2str(idx(iS))]) = inFile1;
    end
    if isfile(inFile2)
        inputs(2).([cochleaID,num2str(idx(iS))]) = inFile2;
    end
    if isfile(inFile3)
        inputs(3).([cochleaID,num2str(idx(iS))]) = inFile3;
    end
    if isfile(inFile4)
        inputs(4).([cochleaID,num2str(idx(iS))]) = inFile4;
    end
    if isfile(inFile5)
        inputs(5).([cochleaID,num2str(idx(iS))]) = inFile5;
    end
end

% Test
for iS = 1:nS
    inputs(:).([cochleaID,num2str(idx(iS))]) % Print to check inputs
    out = ...
        projectnuclearsamplestoroicurve(inputs(:).([cochleaID,num2str(idx(iS))]));
%     pause(5)
    
%     close all
end

cd('F:\projects\cochlea\apps\cochlea-grad-quant.git\src\')
save('Projection-Inputs.mat','inputs')

cd(oworkdir)

clear