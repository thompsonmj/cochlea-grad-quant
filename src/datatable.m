function T = datatable


load(fullfile('..','..','..','data','cochlea-data_2020-07-15_11-36-59.mat'),'data')

e12_flagged = zeros(7,1);
e12_total = zeros(7,1);
e13_flagged = zeros(7,1);
e13_total = zeros(7,1);

nS = numel(data);
for iS = 1:nS
    %% 1. psmad
    idx = 1;
    fname = 'psmad';
    if ~isempty(data(iS).(fname)) && ...
            data(iS).age == 12.5
        e12_total(idx) = e12_total(idx) + 1;
        if data(iS).flag
            e12_flagged(idx) = e12_flagged(idx) + 1;
        end
    elseif ~isempty(data(iS).(fname)) && ...
            data(iS).age == 13.5
        e13_total(idx) = e13_total(idx) + 1;
        if data(iS).flag
            e13_flagged(idx) = e13_flagged(idx) + 1;
        end
    end
    %% 2. sox2
    idx = 2;
    fname = 'sox2';
    if ~isempty(data(iS).(fname)) && ...
            data(iS).age == 12.5
        e12_total(idx) = e12_total(idx) + 1;
        if data(iS).flag
            e12_flagged(idx) = e12_flagged(idx) + 1;
        end
    elseif ~isempty(data(iS).(fname)) && ...
            data(iS).age == 13.5
        e13_total(idx) = e13_total(idx) + 1;
        if data(iS).flag
            e13_flagged(idx) = e13_flagged(idx) + 1;
        end
    end
    %% 3. jag1
    idx = 3;
    fname = 'jag1';
    if ~isempty(data(iS).(fname)) && ...
            data(iS).age == 12.5
        e12_total(idx) = e12_total(idx) + 1;
        if data(iS).flag
            e12_flagged(idx) = e12_flagged(idx) + 1;
        end
    elseif ~isempty(data(iS).(fname)) && ...
            data(iS).age == 13.5
        e13_total(idx) = e13_total(idx) + 1;
        if data(iS).flag
            e13_flagged(idx) = e13_flagged(idx) + 1;
        end
    end
    %% 4. bmp4_mrna
    idx = 4;
    fname = 'bmp4_mrna';
    if ~isempty(data(iS).(fname)) && ...
            data(iS).age == 12.5
        e12_total(idx) = e12_total(idx) + 1;
        if data(iS).flag
            e12_flagged(idx) = e12_flagged(idx) + 1;
        end
    elseif ~isempty(data(iS).(fname)) && ...
            data(iS).age == 13.5
        e13_total(idx) = e13_total(idx) + 1;
        if data(iS).flag
            e13_flagged(idx) = e13_flagged(idx) + 1;
        end
    end
    %% 5. psmad + sox2
    idx = 5;
    fname1 = 'psmad';
    fname2 = 'sox2';
    if ~isempty(data(iS).(fname1)) && ...
            ~isempty(data(iS).(fname2)) && ...
            data(iS).age == 12.5
        e12_total(idx) = e12_total(idx) + 1;
        if data(iS).flag
            e12_flagged(idx) = e12_flagged(idx) + 1;
        end
    elseif ~isempty(data(iS).(fname1)) && ...
            ~ isempty(data(iS).(fname2)) && ...
            data(iS).age == 13.5
        e13_total(idx) = e13_total(idx) + 1;
        if data(iS).flag
            e13_flagged(idx) = e13_flagged(idx) + 1;
        end
    end
    %% 6. psmad + jag1
    idx = 6;
    fname1 = 'psmad';
    fname2 = 'jag1';
    if ~isempty(data(iS).(fname1)) && ...
            ~isempty(data(iS).(fname2)) && ...
            data(iS).age == 12.5
        e12_total(idx) = e12_total(idx) + 1;
        if data(iS).flag
            e12_flagged(idx) = e12_flagged(idx) + 1;
        end
    elseif ~isempty(data(iS).(fname1)) && ...
            ~ isempty(data(iS).(fname2)) && ...
            data(iS).age == 13.5
        e13_total(idx) = e13_total(idx) + 1;
        if data(iS).flag
            e13_flagged(idx) = e13_flagged(idx) + 1;
        end
    end
    %% 7. sox2 + jag1
    idx = 7;
    fname1 = 'sox2';
    fname2 = 'jag1';
    if ~isempty(data(iS).(fname1)) && ...
            ~isempty(data(iS).(fname2)) && ...
            data(iS).age == 12.5
        e12_total(idx) = e12_total(idx) + 1;
        if data(iS).flag
            e12_flagged(idx) = e12_flagged(idx) + 1;
        end
    elseif ~isempty(data(iS).(fname1)) && ...
            ~ isempty(data(iS).(fname2)) && ...
            data(iS).age == 13.5
        e13_total(idx) = e13_total(idx) + 1;
        if data(iS).flag
            e13_flagged(idx) = e13_flagged(idx) + 1;
        end
    end
end

rowNames = { ...
    'psmad', ...
    'sox2', ...
    'jag1', ...
    'bmp4_mrna', ...
    'psmad + sox2', ...
    'psmad + jag1', ...
    'sox2 + jag1' };
T = table(e12_flagged,e12_total,e13_flagged,e13_total, ...
    'RowNames',rowNames);