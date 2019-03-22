classdef CochleaDataObj_modularalign
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
    BAIdcs      % Numeric indices of basal->apical position.
                %  double array
                %  C.BAIdcs      
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
function C = CochleaDataObj_modularalign(fdir)
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
%     fdir = uigetdir;
    finfo = dir( fullfile(fdir, '*.csv') );
    nFiles = size(finfo,1);

    % Create dynamic fieldnames in C.Dat for basal->apical indices:
    % C.Dat.(BAIdx)
    expr1 = '^[^_]+(?=_)'; % Match what preceeds an underscore (section no).
    BAIdx = string;
    C.BAIdcs = zeros(nFiles,1);
    for iFile = 1:nFiles
        [~,fname,~] = fileparts( ...
            fullfile( finfo(iFile).folder,finfo(iFile).name )); 
        [startidx,endidx] = regexp( fname, expr1 ); % Section number.
        no = fname( startidx:endidx );
        BAIdx(iFile) = string( ['S',no] );
        C.BAIdcs(iFile) = str2double(no);
    end     
%     BAIdx = sortit( unique( string(BAIdx) ) );
    BAIdx = sortit( {unique( string(BAIdx) ) } );
    BAIdx = BAIdx{1};
    C.BAIdcs = sort( unique( C.BAIdcs ) );
    nSecs = size(BAIdx,2);
    for iSec = 1:nSecs
        C.Dat.(BAIdx{iSec}) = struct;
    end
    

    % Create dynamic fieldnames for target structs: C.Dat.(BAIdx).(Targets).
    expr2 = '[^_]+$'; % Match what follows an underscore (target name). 
    VALIDTARGETS = ["pSmad","Sox2","TOPRO3"];        
    for iFile = 1:nFiles
        for iSec = 1:nSecs
            [~,fname,fext] = fileparts( ... 
                fullfile( finfo(iFile).folder,finfo(iFile).name )); 
            [startidx1,endidx1] = regexp( fname, expr1 ); % Section number.
            [startidx2,endidx2] = regexp( fname, expr2 ); % Target name.
            no = fname( startidx1:endidx1 );
            t = fname( startidx2:endidx2 );
            if isequal( BAIdx(iSec), string( ['S',no]) ) ...
                    && ismember( t, VALIDTARGETS )
                iBAIdx = num2str( BAIdx{iSec} );
                C.Dat.(iBAIdx).OSR.(t) = struct;
                C.Dat.(iBAIdx).USR.(t) = struct;
%                 C.Dat.(iBAIdx).(t).DatFile = fullfile( fdir, [fname,fext] );
                tFile = [ t, 'File'];
                C.Dat.(iBAIdx).(tFile) = fullfile( fdir, [fname,fext] );
            end
        end
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
            end
        end
    end
    %% Within-cryosection operations.
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
    
    end
end

%% Individual property set methods




end
