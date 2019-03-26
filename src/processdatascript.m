delete(gcp('nocreate'))

if isunix
    fDirList = {...
        '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/2_SW2-1S/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
        '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/4_SW14-3A_assume-serial/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
        '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/5_SW15-1B_assume-serial/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
        '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/9_SW21-1AB/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
%         '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/14_SW18-1AB/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
%         '/depot/dumulis/cochlea/data/img/sw/wt/E12.5/15_SW12-1A/tif-orient/sep-ch/sub-bkgd/sep-z/despeckle/quant-prof/_dat_',
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
elseif ispc
    fDirList = {...
        'F:\projects\cochlea\data\img\sw\wt\E12.5\2_SW2-1S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\4_SW14-3A_assume-serial\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\5_SW15-1B_assume-serial\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\9_SW21-1AB\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
%         'F:\projects\cochlea\data\img\sw\wt\E12.5\14_SW18-1AB\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
%         'F:\projects\cochlea\data\img\sw\wt\E12.5\15_SW12-1A\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\16_SW16-1AB\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\17_SW17-1AB\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\20_SW26-1S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\21_SW26-2S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\22_SW25-1S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\23_SW25-2S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\27_SW28-2S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\28_SW29-1S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_',
        'F:\projects\cochlea\data\img\sw\wt\E12.5\29_SW29-2S\tif-orient\sep-ch\sub-bkgd\sep-z\despeckle\quant-prof\_dat_' ...
        };
end

nDirs = numel( fDirList );

C = cell(nDirs,1);

for iDir = 1:nDirs
    try
        disp(fDirList{ iDir } )
        C{iDir} = CochleaDataObj( fDirList{ iDir } );
        if isunix
            parsave(['/depot/dumulis/cochlea/data/img/sw/wt/E12.5/cochleadata',num2str(iDir),'.mat'],...
            C{iDir})
        elseif ispc
            parsave(['F:\projects\cochlea\data\img\sw\wt\E12.5\cochleadata',num2str(iDir),'.mat'],...
            C{iDir})
        end
    catch
        warning(['Problem with ',fDirList{iDir}])
    end
end

if isunix
    save('/depot/dumulis/cochlea/data/img/sw/wt/E12.5/cochleadata.mat','C')
elseif ispc
    save('F:\projects\cochlea\data\img\sw\wt\E12.5\cochleadata.mat','C')
end