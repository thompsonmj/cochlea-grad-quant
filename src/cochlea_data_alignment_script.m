%% Prep data for alignment.
% 1. Load raw data.
% 2. Apply filter for flagged sections (and resample profiles to have
% uniformly sampled data).
% 3. Regress nuclear noise.
% 4. Smooth using 5% of profile length moving average.
% 5. Include only the middle 80% of each profile to avoid edge effects.
% 6. Normalize each profile such that the mean extrema are anchored to 0
% and 1 (except for nuclear signals).

clear

% load('F:\projects\cochlea\data\cochlea-data_2020-07-27_17-18-56.mat')
% load('F:\projects\cochlea\data\cochlea-data_2020-09-07_17-29-20.mat')
load('F:\projects\cochlea\data\cochlea-data_2020-09-08_17-20-46.mat')


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
            profile_temp = target_temp_in(:,iC);
            % Perform noise regression on this profile using nuclear
            % channel as the noise reference signal.
            if iT < 3 % If not 'topro3', use regression and smooth.
                % Perform noise regression on this profile using nuclear
                % channel as the noise reference signal.
                regression_temp = regressnoise( topro3_temp(:,iC), profile_temp );
                % Smooth the result.
                smoothed_temp = smoothrawdata( regression_temp, 'movmean', win );
                % Include only the middle 80% for further analysis.
                target_temp_out(:,iC) = ...
                    smoothed_temp(round(0.1*nX):round(0.9*nX));
            elseif iT == 3 % If 'topro3', no regression, just smooth.
                smoothed_temp = ...
                    smoothrawdata( topro3_temp(:,iC), 'movmean', win );
                target_temp_out(:,iC) = ...
                    smoothed_temp(round(0.1*nX):round(0.9*nX));
            end
        end
        if iT < 3 % Anchor the mean profile at min = 0 and max = 1.
            flagged_profs.(pairs{iP}).(targets{iP,iT}) = ...
                anchormean0to1(target_temp_out);
        elseif iT == 3 % For 'topro3', anchor mean value to 1.
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
        if iT < 3 % 
            flagged_profs.(pairs{iP}).(targets{iP,iT}) = target_temp_y_align;
        elseif iT == 3
            flagged_profs.(pairs{iP}).(targets{iP,iT}) = ...
                target_temp_y_align./(mean(target_temp_y_align,2));
        end

    end
    % Once each target within a pair has undergone Y-alignment, joint
    % X-alignment can be performed.
    Y_0_temp(:,:,1) = flagged_profs.(pairs{iP}).(targets{iP,1});
    Y_0_temp(:,:,2) = flagged_profs.(pairs{iP}).(targets{iP,2});
        
    [y_temp,~,~,~] = alignxy(Y_0_temp);
    clear Y_0_temp
    
    flagged_profs.(pairs{iP}).(targets{iP,1}) = y_temp(:,:,1);
    flagged_profs.(pairs{iP}).(targets{iP,2}) = y_temp(:,:,2);
end

save('filtered-aligned-cochlea-data.mat','flagged_profs','flagged_data')
