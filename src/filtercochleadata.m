function [filtStructArray, filtTargets] = ...
    filtercochleadata2(inputData, age, flag, targets)
    
% Inputs:
%   > inputData: full struct array containing data for all cochleae
%   > flag: TRUE or FALSE. TRUE: include only sections flagged as representative of
%   thie entire organ. FALSE: include all sections.
%   > targets: cell array containing one or more of the following:
%       psmad, sox2, jag1, topro3, bmp4
%
% Output:
%   > filtData: struct of entries matching the query. Fieldnames correspond
%   to target inputs.

d = inputData;

nSections = numel(inputData);
nTargets = numel(targets);

for iT = 1:nTargets
    filtTargets.(targets{iT}) = [];
end

% filtStructArray = struct;

iFlag = 0;
for iS = 1:nSections
    
    % Check for all desired targets and age in this section.
    for iT = 1:nTargets
        if ~isempty(d(iS).(targets{iT})) && d(iS).age == age
            % great, do nothing yet
        else
            all_targets_tf = false;
            break % this for loop
        end
        all_targets_tf = true;
    end
    
    % Skip section if not all desired targets are present.
    if ~all_targets_tf
        continue % to next section
    end
    
    % Skip section if flag is desired but not in this section.
    if flag && ~d(iS).flag
        continue % to next section
    end
    
    % Made it through the gauntlet.
    iFlag = iFlag + 1;
    
    filtStructArray(iFlag) = d(iS);
    
    for iT = 1:nTargets
        filtTargets.(targets{iT}) = ...
            [filtTargets.(targets{iT}),uniformsample(d(iS).(targets{iT}),1000)];
    end
    
end

end