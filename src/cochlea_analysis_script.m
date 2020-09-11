%%
% 1. Raw data
% 2. Positional error
% 3. Decoding maps
% 4. Point-and-click profiles

load(fullfile('..','..','..','data','filtered-aligned-cochlea-data.mat'))
load('colormaps.mat')
color.topro3 = [0,0,0];

pairs = {'ps12', ...
         'pj12', ...
         'sj12'};%, ...
%          'ps13', ...
%          'pj13'};

targets = {'psmad', 'sox2', 'topro3'; ...
           'psmad', 'jag1', 'topro3'; ...
           'sox2', 'jag1', 'topro3'};% ...
%            'psmad', 'sox2', 'topro3'; ...
%            'psmad', 'jag1', 'topro3'};
% targets = targets';
       
ages = [12.5, ...
        12.5, ...
        12.5];%, ...
%         13.5, ...
%         13.5];
       
[nPairs,nTargets] = size(targets);

%% Raw data
% % % % % % % % % figure
% % % % % % % % % sgtitle('E12.5')
% % % % % % % % % subplot(1,3,1)
% % % % % % % % % hold on
% % % % % % % % % plot(flagged_profs.pj12.psmad,'color',psmad_color)
% % % % % % % % % plot(flagged_profs.pj12.jag1,'color',jag1_color)
% % % % % % % % % % Y(:,:,1) = flagged_profs.pj12_prof.psmad;
% % % % % % % % % % Y(:,:,2) = flagged_profs.pj12_prof.jag1;
% % % % % % % % % % pj12_sigma_x = positionalerrorn(Y);
% % % % % % % % % 
% % % % % % % % % subplot(1,3,2)
% % % % % % % % % hold on
% % % % % % % % % plot(flagged_profs.ps12.psmad,'color',psmad_color)
% % % % % % % % % plot(flagged_profs.ps12.sox2,'color',sox2_color)
% % % % % % % % % 
% % % % % % % % % subplot(1,3,3)
% % % % % % % % % hold on
% % % % % % % % % plot(flagged_profs.sj12.sox2,'color',sox2_color)
% % % % % % % % % plot(flagged_profs.sj12.jag1,'color',jag1_color)
% % % % % % % % % 
% % % % % % % % % figure
% % % % % % % % % sgtitle('E13.5')
% % % % % % % % % subplot(1,3,1)
% % % % % % % % % hold on
% % % % % % % % % plot(flagged_profs.pj13.psmad,'color',psmad_color)
% % % % % % % % % plot(flagged_profs.pj13.jag1,'color',jag1_color)
% % % % % % % % % 
% % % % % % % % % subplot(1,3,2)
% % % % % % % % % hold on
% % % % % % % % % plot(flagged_profs.ps13.psmad,'color',psmad_color)
% % % % % % % % % plot(flagged_profs.ps13.sox2,'color',sox2_color)

%% 2. Positional error
% Individual profiles
% pj12: psmad
% ps12: psmad
% pj12: jag1
% sj12: jag1
% ps12: sox2
% sj12: sox2
%
% pj13: psmad
% ps13: psmad
% pj13: jag1
% ps13: sox2

x = [0.1:0.001:0.9];
for iP = 1:nPairs
    for iT = 1:2
        y_temp = flagged_profs.(pairs{iP}).(targets{iP,iT});
        y_temp_mean = mean(y_temp,2);
        sigX.(pairs{iP}).(targets{iP,iT}) = ...
            positionalerror(y_temp);
        
        figure
        hold on
        yyaxis left
        plot(x',y_temp_mean,'color',color.(targets{iP,iT}),'linew',2)
        s = shadedErrorBar(x,y_temp',{@mean,@std});
        s.patch.FaceColor = color.(targets{iP,iT});
        ylim([0,1.1])
        
        yyaxis right
        plot(x(1:end-1),sigX.(pairs{iP}).(targets{iP,iT}));
        ylim([0,0.1])
        
    end
end



