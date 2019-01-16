% # Pseudocode
% . Select a folder containing all images to process in a session with e.g. uigetdir
%     - e.g. USB30FD/projects/cochlea/data/img/10/_dat
% . import all .czi images
% . convert all to .tif stacks, removing the corresponding .czi from memory after each conversion to prevent overflowing
% . separate channels for each optical section for each tissue section and save to disk under new dir
%     - e.g. .../data/img/10/tif/sep-chan/>ch-metadata</_dat
%     - where >channel-metadata< includes the laser, antibody info, and target e.g. 568-Sox2-goat1Ab_donkey2AbAF568
%     - Keep this naming scheme consistant:
%      >laserChannel-targetMolecule-taggingInfo<
% 
% --- All following manual steps should be done 3x per specimen froms start to finish to account for variability. Workflow is:
% ~ experiment 1
%     FIRST REPLICATE
%     ~ tissue section 1
%         ~ optical section 1
%             . remove bkgd **MANUAL VARIATION**
%             . remove speckling as needed(always use identical parameters across all experiments and samples in an experiment - this code should be run on every image in an experiment if it is run on any image in an experiment)
%             . set ROI **MANUAL VARIATION**
%             . extract data **MANUAL VARIATION**
%             . generate plots (always use identical profile smoothing parameters across all experiments and samples in an experiment)
%         ~ optical section 2
%             . ...
%     ~ tissue section 2
%         ~ optical section 1
%             . ...
%         ~ optical section 2
%             . ...
%         ~ ...
%         ~ optical section n
%             . ...
%     ~ ...
%     ~ tissue section n
%         ~ optical section 1
%             . ...
%         ~ ...
%         ~ optical section n
%             . ...
%     SECOND REPLICATE
%     ~ tissue section 1
%         ...
%     THIRD REPLICATE
%     ~ tissue section 1
%         ...
% end experiment
% 
% Above sources of variation are generated on a single set of raw data.
% 
% Additional sources of variation in generating raw data: 
% . embryo age (supposedly limited to +/- 0.25 days)
% . embryo orientation
%     - cochlea orientation within embryo
%     - embryo orientation within OCT block
%     - OCT block orientation on cryotome block
% . staining variation
%     - single target, antibody, protocol, etc. 
%         - across >1 slide (different exact reagent quantities) in same embryo
%         - across >1 slide (different exact reagent quantities) and different embryos in same litter (different embryo genetics and physiology, different preparation conditions)
%         - ...
% 
% 
% Procedure:
% . subtract bkgd from each optical section for each tissue section (from instrument and sample)
%     - (auto) open a channel's stack in Fiji
%     - (auto) open ROI manager
%     - (man) select several (O(10)) small regions in scala media where there is no tissue in any z-plane
%     - (man) save ROI to disk under >ch-metadata</rm-bkgd/ibn-roi1/_dat
%     
% . Set ROI along sensory epithelium
% 
% . Extract data for each channel, for each optical section, for each tissue section
% 
% . Plot and normalize (against nuclear, across samples) best optical section for each tissue section
% 
% ....
% 
% ALTERNATIVELY
% 3D Cochlea Reconstruction Interpolating Across Multiple Tissue Sections
% . Cell segmentation and alignment does not seem like a good option - no direct nuclear overlap between tissue sections
%     - Tissue sections should therefore be as thick as possible to gather as much information
 
loadimagej

% Open one image at a time in ImageJ.

%%% Might not be the right time to import data to MATLAB
%%% Load raw image data into MATLAB.
%%%[rawFileInfo, rawData] = loadimages;

% Full stack: rawData{iSample,1}{1,1}{zc,1}
% Single image: rawData{iSample,1}{1,1}{zc,1}, zc index iterates thru each channel (first) at each z
% Single image name/info: rawData{iSample,1}{1,1}{zc,2}


