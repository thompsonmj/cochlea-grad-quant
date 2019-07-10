function [ RawDat ] = getrawcochleadata( fdir )
%GETRAWCOCHLEADATA returns the raw signaling data for one organ.
%
% Input: 
%   > fdir: directory holding data files
% Output:
%  > rawCircPsn: circumferential position [microns]
%  > RawDat: struct holding: 
%       .ba: 1 | 2 corresponding to basal | apical, respectively
%       .idxba: section index relative to basal-most section in the
%           basal/apical region as defined in .ba
%       .psn: circumferential position [microns]
%       .<targetname>: expression data for each target

startDir = pwd;
% fdir = 'Z:\cochlea\data\img\sw\wt\E12.5\32_SW32-2S\tif-orient\sep-ch\mip\despeckle\quant-prof';
cd(fdir)
finfo = dir( fullfile(fdir, '*.csv') );
fNames = sortit( {finfo.name} ); % Formatted as '<filename>.<ext>'.
nFiles = numel(fNames);

RawDat = struct;

for iFile = 1:nFiles
    f = fullfile( finfo(iFile).folder, finfo(iFile).name );
    [~,fname,~] = fileparts( f );
    % fname e.g. 'B1_pSmad', 'A3_Sox2'. B: basal, A: apical
    BorAchar = fname(1);
    idx_ba = str2num( fname(2) );
    ch = fname(4:end);
    if BorAchar == 'B'
        BorAno = 1;
    elseif fname(1) == 'A'
        BorAno = 2;
    else
        msg = ['File "',fname,'" in "',fdir,'" is incorrectly labeled.'];
        error(msg)
    end
    
    if iFile == 1
        idx_sec = 1;
        RawDat(idx_sec).ba = BorAno;
        RawDat(idx_sec).idxba = idx_ba;
        [psn,expr] = parsecsvLOCAL( f );
        RawDat(idx_sec).psn = psn;
        RawDat(idx_sec).(ch) = expr;
    else
        if idx_ba == RawDat(idx_sec).idxba && BorAno == RawDat(idx_sec).ba
            [~,expr] = parsecsvLOCAL( f );
            RawDat(idx_sec).(ch) = expr;
        else
            idx_sec = idx_sec + 1;
            RawDat(idx_sec).ba = BorAno;
            RawDat(idx_sec).idxba = idx_ba;
            [psn,expr] = parsecsvLOCAL( f );
            RawDat(idx_sec).psn = psn;
            RawDat(idx_sec).(ch) = expr;

        end
    end

    
end

cd(startDir)

end

% LOCAL FUNCTIONS
function [psn, expr] = parsecsvLOCAL( f )

% fprintf('Importing data from section %i of %i.\n',iSec,nSecs)

d = delimread(f,',','mixed');
psn = cat( 1, d.mixed{3:end,1} );
len = max(psn);
disp(f)
disp(len)

if len > 1000
    disp(['Invalid length for ',f]);
    psn = 0;
    expr = 0;
    return
end
% assert(len < 1000, 'Invalid length.');
    % Catches error if position is mistakenly not converted from points to
    % microns. All radial sections should be less than 1000 microns long.
expr = d.mixed(3:end,2:end); % Index data within cell array.
expr = cell2mat(expr);

% If image is 8-bit, scale to 16-bit.
maxVal = max( max(expr) );
if maxVal < 256
    expr = expr*256;
end


end