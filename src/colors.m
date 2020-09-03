%% Add ref to color palette source
% Probably taken from here: https://colorpalettes.net
%%
jag1_color = [51,153,51]./255;   % Green
sox2_color = [51,102,153]./255;  % Blue
psmad_color = [180,133,0]./255;  % Gold
topro3_color = [255,255,255]./255; % White
% bmp4_mrnaColor = []./255; % Yellow


range = 64; % Number of color gradations.
% map0 = zeros(range,3);
scale = [1/range:1/range:1]';

% Multiplier needs to be optimized to maximize all RGB without exceeding 1.
% different for each channel/map
% while 
whitener = 20;

jag1_multiplier = 1.65;
cmap_jag1 = repmat(jag1_color,range,1).*scale*jag1_multiplier;
sox2_multiplier = 1.65;
cmap_sox2 = repmat(sox2_color,range,1).*scale*sox2_multiplier;
psmad_multiplier = 1.41;
cmap_psmad = repmat(psmad_color,range,1).*scale*psmad_multiplier;
cmap_topro3 = repmat(topro3_color,range,1).*scale;



jag1_img_dir = 'F:\projects\cochlea\data\img\sw\wt\E12.5\38_SW43-2AB_topro3-jag1-sox2\tif-orient\sep-ch\mip\despeckle\_data_';
jag1_img_file = 'B3_ch1-jag1_mip_sec-img.tif';

sox2_img_dir = jag1_img_dir;
sox2_img_file = 'B3_ch3-sox2_mip_sec-img.tif';

topro3_img_dir = jag1_img_dir;
topro3_img_file = 'B3_ch2-topro3_mip_sec-img.tif';

psmad_img_dir = 'F:\projects\cochlea\data\img\sw\wt\E12.5\30_SW33-1S_topro3-sox2-psmad\tif-orient\sep-ch\mip\despeckle\_data_';
psmad_img_file = 'B6_ch3-psmad_mip_despeckled_sec-img.tif';

thisDir = sox2_img_dir;
thisImg = sox2_img_file;
thisMap = cmap_sox2;

img = imread(fullfile(thisDir,thisImg));

% jag1_cmap = repmat(jag1Color,range,1).*scale;
figure
imagesc(img)
truesize
c = colormap(thisMap);
% title(num2str(multiplier))
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])
