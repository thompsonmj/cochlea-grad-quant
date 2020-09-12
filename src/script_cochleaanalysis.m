%%
% 1. [X] Raw data
% 2. [X] Positional error
% 3. [ ] Decoding maps
% 4. [ ] Point-and-click profiles
clear
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

%% 
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

figure
hold on
for iP = 1:nPairs

    for iT = 1:2
        y_temp = flagged_profs.(pairs{iP}).(targets{iP,iT});
        y_temp_mean = mean(y_temp,2);
        
        % Row 1 - Raw Data
        subplot(4,nPairs,iP)
        hold on
        plot(x,y_temp,'color',color.(targets{iP,iT}))
        ylim([-0.2,1.2])
        
        
        sigX.(pairs{iP}).(targets{iP,iT}) = ...
            positionalerror(y_temp);
        
        % Rows 2 and 3 - Mean, STD, PE for 1 target in a pair
        subplot(4,nPairs,iP+3*iT)
        yyaxis left
        plot(x',y_temp_mean,'color',color.(targets{iP,iT}),'linew',2)
        s = shadedErrorBar(x,y_temp',{@mean,@std});
        s.patch.FaceColor = color.(targets{iP,iT});
        ylim([-0.2,1.2])
        
        yyaxis right
        plot(x(1:end-1),sigX.(pairs{iP}).(targets{iP,iT}));
        ylim([0,0.1])
        ylabel('\sigma_x/L')
        
        % Row 4 - Mean, STD, PE for both targets in a pair
        subplot(4,nPairs,iP+9)
        hold on
        yyaxis left
        plot(x',y_temp_mean,'color',color.(targets{iP,iT}),'linew',2)
        s = shadedErrorBar(x,y_temp',{@mean,@std});
        s.patch.FaceColor = color.(targets{iP,iT});
        ylim([-0.2,1.2])

        Y_temp(:,:,iT) = flagged_profs.(pairs{iP}).(targets{iP,iT});
        
    
    end
    [nPts,~,~] = size(Y_temp);

    subplot(4,nPairs,iP+9)
    yyaxis right
    sigX_pair = positionalerrorn(Y_temp)/nPts;
    plot(x,sigX_pair)
    ylim([0,0.1])
    ylabel('\sigma_x/L')

    clear Y_temp
    
end


