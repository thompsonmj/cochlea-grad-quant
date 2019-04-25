delete(gcp('nocreate')) % Prevents error when a parallel pool is already running.

if isunix
    tilde = fullfile('umulis','dumulis','cochlea','data','img');
elseif ispc
    tilde = 'F:\projects';
end
baseDir = fullfile(tilde,'cochlea','data','img','sw','wt','E12.5');
dataDir = fullfile('tif-orient','sep-ch','sub-bkgd','sep-z','despeckle','quant-prof','_dat_');

fDirList = {...
%     fullfile(baseDir,'2_SW2-1S',dataDir), % questionable data quality
    fullfile(baseDir,'4_SW14-3A_assume-serial',dataDir), 
    fullfile(baseDir,'5_SW15-1B_assume-serial',dataDir), 
    fullfile(baseDir,'9_SW21-1AB',dataDir), 
    fullfile(baseDir,'14_SW18-1AB',dataDir),% questionable data quality
    fullfile(baseDir,'15_SW12-1A',dataDir),% questionable data quality
    fullfile(baseDir,'16_SW16-1AB',dataDir),
    fullfile(baseDir,'17_SW17-1AB',dataDir),
    fullfile(baseDir,'20_SW26-1S',dataDir), 
    fullfile(baseDir,'21_SW26-2S',dataDir), 
    fullfile(baseDir,'22_SW25-1S',dataDir), 
    fullfile(baseDir,'23_SW25-2S',dataDir), 
    fullfile(baseDir,'27_SW28-2S',dataDir), 
    fullfile(baseDir,'28_SW29-1S',dataDir), 
    fullfile(baseDir,'29_SW29-2S',dataDir)
    };

nDirs = numel( fDirList );

C = cell(nDirs,1);

parfor iDir = 1:nDirs
    try
        disp(fDirList{ iDir } )
        C{iDir} = CochleaDataObj_MaxProj( fDirList{ iDir } );
        saveDir = baseDir;
        parsave( fullfile(saveDir,['cochleadata',num2str(iDir),'.mat']), ...
            C{iDir} );
    catch
        warning(['Problem with ',fDirList{iDir}])
    end
end

saveDir = baseDir;
save( fullfile(saveDir,['cochleadataFULL.mat']), 'C' );