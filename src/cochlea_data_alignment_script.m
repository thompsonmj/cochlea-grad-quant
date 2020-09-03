load('F:\projects\cochlea\data\cochlea-data_2020-07-27_17-18-56.mat')

pairs = {'ps12', ...
         'pj12', ...
         'sj12', ...
         'ps13', ...
         'pj13'};

targets = {'psmad', 'sox2', 'topro3'; ...
           'psmad', 'jag1', 'topro3'; ...
           'sox2', 'jag1', 'topro3'; ...
           'psmad', 'sox2', 'topro3'; ...
           'psmad', 'jag1', 'topro3'};
       
ages = [12.5, ...
        12.5, ...
        12.5, ...
        13.5, ...
        13.5];
       
[nPairs,nTargets] = size(targets);

%% Prep data for alignment.
% Load data.
% Regress nuclear noise.
% Smooth using 5% of profile length moving average.

nX = 1000;

win = round(nX*0.05); % Smoothing window.
for iP = 1:nPairs
    [flagged_data.(pairs{iP}), flagged_profs.(pairs{iP})] = ...
        filtercochleadata(data, ages(iP), true, targets(iP,:));

    topro3_temp = flagged_profs.(pairs{iP}).topro3;

    [nX,nCochleae] = size(topro3_temp);

    for iT = 1:3 % Targets
        % Isolate the profiles for a single target.
        target_temp_in = flagged_profs.(pairs{iP}).(targets{iP,iT});
        % Initialize output (to use only middle 80% of each profile).
        target_temp_out = zeros(round(nX*0.8)+1,nCochleae);
        for iC = 1:nCochleae
            % Isolate a single profile.
            prof_temp = target_temp_in(:,iC);
            % Perform noise regression on this profile using nuclear
            % channel as the noise reference signal.
            if iT < 3 % If not 'topro3', use regression.
                % Perform noise regression on this profile using nuclear
                % channel as the noise reference signal.
                reg_temp = regressnoise( topro3_temp(:,iC), prof_temp );
                % Smooth the result.
                smoothed_temp = smoothrawdata( reg_temp, 'movmean', win );
                % Include only the middle 80% for further analysis.
                target_temp_out(:,iC) = ...
                    smoothed_temp(round(0.1*nX):round(0.9*nX));
            elseif iT == 3 % If 'topro3', no regression.
                smoothed_temp = ...
                    smoothrawdata( topro3_temp(:,iC), 'movmean', win );
                target_temp_out(:,iC) = ...
                    smoothed_temp(round(0.1*nX):round(0.9*nX));
            end
        end
        if iT < 3
            flagged_profs.(pairs{iP}).(targets{iP,iT}) = ...
                anchormean0to1(target_temp_out);
        elseif iT == 3
            flagged_profs.(pairs{iP}).(targets{iP,iT}) = ...
                target_temp_out./mean(target_temp_out,2);
        end
    end
end



%% Perform alignments
% Initial Y-alignment
for iP = 1:nPairs
    for iT = 1:3
        target_temp_in = flagged_profs.(pairs{iP}).(targets{iP,iT});
        target_temp_y_align = aligny(target_temp_in);
        if iT < 3
            flagged_profs.(pairs{iP}).(targets{iP,iT}) = target_temp_y_align;
        elseif iT == 3
            flagged_profs.(pairs{iP}).(targets{iP,iT}) = ...
                target_temp_y_align./(mean(target_temp_y_align,2));
        end

    end
    
end

%%



load('colormaps.mat')



figure
subplot(1,3,1)
hold on
plot(pj12_prof.psmad,'color',psmad_color)
plot(pj12_prof.jag1,'color',jag1_color)
Y(:,:,1) = pj12_prof.psmad;
Y(:,:,2) = pj12_prof.jag1;
pj12_sigma_x = positionalerrorn(Y);


subplot(1,3,2)
hold on
plot(ps12_prof.psmad,'color',psmad_color)
plot(ps12_prof.sox2,'color',sox2_color)

subplot(1,3,3)
hold on
plot(sj12_prof.sox2,'color',sox2_color)
plot(sj12_prof.jag1,'color',jag1_color)

figure
subplot(1,3,1)
hold on
plot(pj13_prof.psmad,'color',psmad_color)
plot(pj13_prof.jag1,'color',jag1_color)

subplot(1,3,2)
hold on
plot(ps13_prof.psmad,'color',psmad_color)
plot(ps13_prof.sox2,'color',sox2_color)

