fDirList = {...
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/2_SW2-1S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/4_SW14-3A_assume-serial/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/5_SW15-1B_assume-serial/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/9_SW21-1AB/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/14_SW18-1AB/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/15_SW12-1A/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/16_SW16-1AB/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/17_SW17-1AB/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/20_SW26-1S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/21_SW26-2S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/22_SW25-1S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/23_SW25-2S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/27_SW28-2S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/28_SW29-1S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
    '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/29_SW29-2S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_' ...
    };

nDirs = numel( fDirList );

C = cell(nDirs,1);

for iDir = 1:nDirs
    try
        disp(fDirList{ iDir} )
        C{iDir} = CochleaDataObj_modularalign( fDirList{ iDir } );
        parsave(['/depot/dumulis/cochlea/data/img/sw/wt/E12.5/cochleadata',num2str(iDir),'_cluster.mat'],...
            C{iDir})
    catch
        warning(['Problem with ',fDirList{iDir}])
    end
end

% save('F:\projects\cochlea\data\img\sw\wt\E12.5\cochleadata.mat',C)
