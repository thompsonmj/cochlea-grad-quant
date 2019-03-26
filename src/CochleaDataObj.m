classdef CochleaDataObj
% Structure:
% ???Make a superclass where each CochleaDataObj instance is a property of it.
%%%TODO add inclusion logic flag under target - easily include/exclude data
%% Properties
properties (SetAccess = private)
    CochleaID   % ID code unique to the organ this data is from.
                %  char array
                %  C.CochleaID
    SlideID     % ID code of the microscope slide(s) this data is from.
                %  char array 
                %  C.SlideID
    Age         % Nominal age represented in days post coitum.
                %  char array
                %  C.Age
    SecTh       % Cryosection thickness [microns].
                %  double
                %  C.SecTh   
%     BAIdcs      % Numeric indices of basal->apical position.
                %  double array
                %  C.BAIdcs      
    B_BAIdcs
    A_BAIdcs
    Dat         % Profile data.
                %  struct
                %  C.Dat
%   BAIdx       % Indices of basal->apical cryosection posiiton.
                %  struct, dynamic from filenames, 's' appended to front to
                %  represent 'section'.
                %  C.Dat.(BAIdx), e.g. C.Dat.s1
%   rawCircPsn  % Radial position [microns]. Raw size.
                %  double array
                %  C.Dat.(BAIdx).rawCircPsn
%   RadPsn      % Radial position [microns]. Uniform size
                %  double array
                %  C.Dat.(BAIdx).RadPsn
%   circLen     % Circumferencial length, x = L.
                %  double
                %  C.Dat.(BAIdx).circLen
%%%TODO   SecAng      % Cryosection angle to viewing plane [degrees].
                %  double
                %  C.Dat.(BAIdx).SecAng            
%   Targets     % Molecular target represented by the data.
                %  struct, dynamic from filenames. 
                %  C.Dat.(BAIdx).(Targets), e.g. C.Dat.s1.pSmad
%   RawDat      % Raw profile data. Raw size.
                %  double array
                %  C.Dat.(BAIdx).(Targets).RawDat
%   AlgnDat     % Aligned data. Aligned by pSmad peaks. Uniform size.
                %  double array
                %  C.Dat.(BAIdx).(Targets).AlgnDat
%   MnDat       % Mean of aligned raw data for each section. Uniform size.
                %  double array
                %  C.Dat.(BAIdx).(Targets).MnDat
%   STDDat      % Standard deviation of aligned raw data. Uniform size.
                %  double array
                %  C.Dat.(BAIdx).(Targets).STDDat
%   SEMDat      % Standard error of the mean of aligned raw data.
                %  double array
                %  C.Dat.(BAIdx).(Targets).SEMDat
%   smAlgnDat   % Smooth aligned data. Aligned by pSmad peaks. Uniform size.
                %  double array
                %  C.Dat.(BAIdx).(Targets).AlgnDat
%   smMnDat     % Smooth mean of aligned raw data for each section. Uniform size.
                %  double array
                %  C.Dat.(BAIdx).(Targets).MnDat
%   smSTDDat    % Smooth standard deviation of aligned raw data. Uniform size.
                %  double array
                %  C.Dat.(BAIdx).(Targets).STDDat
%   smSEMDat    % Smooth standard error of the mean of aligned raw data.
                %  double array
                %  C.Dat.(BAIdx).(Targets).SEMDat

%     Thirds      % Data grouped into basal->apical thirds
%     Quarts      % Data grouped into basal->apical quartiles
%     Quints      % Data grouped into basal->apical quintiles
%     MetaData    % Imaging metadata from microscope.
%                 %   ...  
%     BAOffset    % Approx no of sections section '1' is offset from base.
%                 %  double    
%     what else?
end
methods
%% Constructor
function C = CochleaDataObj(varargin)
    C.CochleaID = genidcode;
        
%     prompt = 'Enter the slide ID in single quotes (e.g. ''SW1_1S''): ';
%     id = input(prompt);
%     assert(ischar(id),'Input must be a character array.')
%     C.SlideID = id;
%    
%     prompt = 'Enter the embryo age in dpc in single quotes(e.g. ''E12.5''): ';
%     age = input(prompt);
%     VALIDAGES = ["E12.5" "E13.5" "E14.5" "E15.5"];
%     assert(ismember(age,VALIDAGES),'Invalid entry.')
%     C.Age = age;
%    
%     prompt = 'Enter the cryosection thickness in microns: ';
%     th = input(prompt);
%     assert(isnumeric(th) && th<=20,'Invalid entry.');
%     C.SecTh = th;

    C.SlideID = 'test';
    C.Age = 'E12.5';
    C.SecTh = 15;
    
    %% Parse through data files to organize and store raw data.
    nArgs = numel(varargin);
    switch nArgs
        case 0
            fdir = uigetdir;
        case 1
            fdir = varargin{1};
%             assert(isfolder(fdir), ...
%                 'Argument must be a valid accessible directory.');
        otherwise
            error('Invalid argument number.')
    end
    finfo = dir( fullfile(fdir, '*.csv') );
    fNames = {finfo.name}; % Name + extension.
    fNames = sortit(fNames);
    nFiles = size(finfo,1);

    % Create dynamic fieldnames in C.Dat for basal->apical indices:
    % C.Dat.(BAIdx)
    exprABN = '^[^_]+(?=_)'; % Match what preceeds an underscore (section no).
    BAIdx = string;
%     C.BAIdcs = zeros(nFiles,1);
    for iFile = 1:nFiles
        [~,fname,~] = fileparts( ...
            fullfile( finfo(iFile).folder,finfo(iFile).name )); 
        [startIdxABN,endIdxABN] = regexp( fname, exprABN ); % A/B+Section number.
        no = fname( startIdxABN:endIdxABN );
        BAIdx(iFile) = string( no );
    end     
    BAIdx = sortit( unique( cellstr(BAIdx) ) );
    nSecs = size(BAIdx,2);
    
    exprBN = '(?<=B)(\d*)';
    exprAN = '(?<=A)(\d*)';
    C.B_BAIdcs = [];
    C.A_BAIdcs = [];
    for iSec = 1:nSecs
        section = BAIdx{iSec};
        [startIdxBN,endIdxBN] = regexp( section, exprBN );
        [startIdxAN,endIdxAN] = regexp( section, exprAN );
        C.B_BAIdcs = [C.B_BAIdcs, str2num( section( startIdxBN:endIdxBN ) )];
        C.A_BAIdcs = [C.A_BAIdcs, str2num( section( startIdxAN:endIdxAN ) )];
    end
    for iSec = 1:nSecs
        C.Dat.(BAIdx{iSec}) = struct;
    end
    

    % Create dynamic fieldnames for target structs: C.Dat.(BAIdx).(Targets).
    % Match what follows an underscore and precedes a period (target name).
    exprT = '(?<=_)\w+(?=.)'; 
    VALIDTARGETS = ["pSmad","Sox2","TOPRO3"];        
    for iFile = 1:nFiles
        f = fNames{iFile};
        [startIdxABN,endIdxABN] = regexp( f, exprABN ); % A/B+Section number.
        no = f( startIdxABN:endIdxABN );
        [startIdxT,endIdxT] = regexp( f, exprT );
        t = f( startIdxT:endIdxT );
        C.Dat.(no).OSR.(t) = struct;
        C.Dat.(no).USR.(t) = struct;
        tFile = [ t, 'File'];
        C.Dat.(no).(tFile) = fullfile( fdir, f );
    end

    % Parse data from files.
    for iSec = 1:nSecs
        fprintf('Importing data from section %i of %i.\n',iSec,nSecs)
        Ttemp = fieldnames( C.Dat.(BAIdx{iSec}).OSR );
        nFields = size(Ttemp,1);
        T = {};
        Tfiles = {};
        for iField = 1:nFields
            if ismember( Ttemp{iField}, VALIDTARGETS )
                T = [ T, Ttemp{iField} ];
                Tfiles = [ Tfiles, [Ttemp{iField},'File'] ];
            end
        end
        nTgts = numel(T);
        for iTgt = 1:nTgts
            C.Dat.(BAIdx{iSec}).OSR.(T{iTgt});
            d = delimread( ...
                C.Dat.(BAIdx{iSec}).(Tfiles{iTgt}),',','mixed');
            C.Dat.(BAIdx{iSec}).OSR.circPsn = cat( 1, d.mixed{3:end,1} ); %%% Rewrites same value for every target.
            C.Dat.(BAIdx{iSec}).circLen = max( C.Dat.(BAIdx{iSec}).OSR.circPsn );%%% so does this
            
            assert(C.Dat.(BAIdx{iSec}).circLen < 1000,'Invalid length.');
                % Catches error if distance mistakenly is not converted
                % from points to microns. All radial sections should be
                % less than 1000 microns in circumference.
            A = d.mixed(3:end,2:end); % Index data within cell array.
            A = cell2mat(A);
            
            % Only include data with 3 or more optical sections.
            if size(A,2) >= 3
                % If image is 8-bit, scale to 16-bit.
                maxVal = max( max( A ) );
                if maxVal < 256
                    A = A*256;
                end

                % Ensure bit depth is not over 16-bit.
                assert(maxVal < 65536,'Invalid bit depth.');

                C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).rawDat = A;
            else
                % Skip assignment of this data.
                warning( ['%s channel in section %i of %i contains %i ', ...
                    'optical sections. Excluding this data.'], ...
                    T{iTgt}, iSec, nSecs, size(A,2) )
                % Remove this target from the object.
                C.Dat.(BAIdx{iSec}).OSR = ...
                    rmfield( C.Dat.(BAIdx{iSec}).OSR, T{iTgt} );
            end
        end
    end
    %% Within-cryosection operations.
    secToDelete = {};
    for iSec = 1:nSecs
        %% Setup for RawDat and circPsn.
        circPsn = C.Dat.(BAIdx{iSec}).OSR.circPsn;
        RawDat = struct; % Inverts from *.(Target).RawDat to RawDat.(Target)
        Ttemp = fieldnames( C.Dat.(BAIdx{iSec}).OSR );
        nFields = size( Ttemp, 1 );
        T = {};
        for iField = 1:nFields
            if ismember( Ttemp{iField}, VALIDTARGETS )
                T = [ T, Ttemp{iField} ];
            end
        end
        nTgts = numel(T);
        for iTgt = 1:nTgts
            RawDat.(T{iTgt}) = C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).rawDat;
        end
        %% Check that data was accepted and imported.
        if numel( fieldnames( RawDat ) ) == 0
            secToDelete = [secToDelete, BAIdx{iSec}];
            % Delete C.Dat.(SNUMBER)
            % Delete B_BAIdcs or A_BAIdcs entry
            % Skip to next section.
            continue
        end
        %% (1) Smooth raw data.
        SmRawDat = smoothrawdata( RawDat, circPsn );
        %% (2) Norm smoothed data.
        fprintf('Normalizing data in section %i of %i.\n',iSec,nSecs)
        NormDat = chisqnormwrapper( SmRawDat );
        for iTgt = 1:nTgts
            NormDatChiSq.(T{iTgt}) = NormDat.(T{iTgt}).chiSq;
        end
        %% (3) Average data.
        for iTgt = 1:nTgts
            meanNormDat.(T{iTgt}) = mean( NormDatChiSq.(T{iTgt}), 2 );
        end
        %% (4) Align data.
        algnMode = 'com';
        PERCENTILE = 1/3;
        
        DatToAlgn.SmNorm = NormDatChiSq;
        template = meanNormDat.pSmad;
        AlNormDat = ...
            alignpeaks( DatToAlgn, template, algnMode, PERCENTILE );
        clear datToAlgn;
        for iTgt = 1:nTgts
            C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).algnDat = ...
                AlNormDat.SmNorm.(T{iTgt});
        end
        %% Resample aligned data at a uniform sampling rate.
        NSAMPLES = 1000;
        
        C.Dat.(BAIdx{iSec}).USR.circPsn = uniformsample( circPsn, NSAMPLES );
        
        for iTgt = 1:nTgts
            C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).rawDat = ...
                uniformsample( RawDat.(T{iTgt}), NSAMPLES );
            C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).algnDat = ...
                uniformsample( AlNormDat.SmNorm.(T{iTgt}), NSAMPLES );
        end
        %% Statistics within cryosections.
        WEIGHT = 0; % for standard deviation
        nZ = size( C.Dat.(BAIdx{iSec}).OSR.(T{1}).rawDat, 2 );
        for iTgt = 1:nTgts
            % Mean
            C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).mn = ...
                mean( C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).algnDat, 2 );
            C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).mn = ...
                mean( C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).algnDat, 2 );
            % Standard deviation
            C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).std = ...
                std( C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).algnDat, WEIGHT, 2 );
            C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).std = ...
                std( C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).algnDat, WEIGHT, 2 );
            % Standard error to the mean.
            C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).sem = ...
                (1/sqrt(nZ))*C.Dat.(BAIdx{iSec}).OSR.(T{iTgt}).std;
            C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).sem = ...
                (1/sqrt(nZ))*C.Dat.(BAIdx{iSec}).USR.(T{iTgt}).std;
        end
    end    

    % If there are sections that have not imported any data due to
    % insufficient numbers of optical sections at all channels, delete
    % them.
    nDels = numel(secToDelete);
    Alist = [];
    Blist = [];
    for iDel = 1:nDels
        C.Dat = rmfield( C.Dat,secToDelete{iDel} );
        % Check if Apical or Basal
        % If A, add idx to A list
        % If B, add idx to B list
        % Delete A list from C.A_BAIdcs
        % Delete B list from C.B_BAIdcs
        
        if ~isempty( regexp(secToDelete{iDel},'^A', 'once') )
            % Apical half
            str = secToDelete{iDel};
            entry = str(2);
            Alist = [Alist, str2num(entry)];
        elseif ~isempty( regexp(secToDelete{iDel},'^B', 'once') )
            % Basal half
            str = secToDelete{iDel};
            entry = str(2);
            Blist = [Blist, str2num(entry)];
        else
            %something is wrong.
        end
        [~,ADelIdcs] = ismember(Alist,C.A_BAIdcs);
        [~,BDelIdcs] = ismember(Blist,C.B_BAIdcs);
        
        if ~isempty(ADelIdcs)
            C.A_BAIdcs(ADelIdcs) = [];
        end
        if ~isempty(BDelIdcs)
            C.B_BAIdcs(BDelIdcs) = [];
        end
        
    end
    
end
end

%% Individual property set methods




end
