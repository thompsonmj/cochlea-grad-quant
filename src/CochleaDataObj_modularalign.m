cclassdef CochleaDataObj
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
    BAIdxAr     %TODO Numeric indices of basal->apical position.
                %  double array
                %  C.BAIdxAr      
    Dat         % Profile data.
                %  struct
                %  C.Dat
%   BAIdx       % Indices of basal->apical cryosection posiiton.
                %  struct, dynamic from filenames, 's' appended to front to
                %  represent 'section'.
                %  C.Dat.(BAIdx), e.g. C.Dat.s1
%   RawRadPsn   % Radial position [microns]. Raw size.
                %  double array
                %  C.Dat.(BAIdx).RawRadPsn
%   RadPsn      % Radial position [microns]. Uniform size
                %  double array
                %  C.Dat.(BAIdx).RadPsn
%   RadLen      % Radial length, x = L.
                %  double
                %  C.Dat.(BAIdx).RadLen
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
function C = CochleaDataObj
    tic
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
    
    % Parse through data files to organize and store raw data.
    fdir = uigetdir;
    finfo = dir( fullfile(fdir, '*.csv') );
    nFiles = size(finfo,1);

    % Create dynamic fieldnames in C.Dat for basal->apical indices:
    % C.Dat.(BAIdx)
    expr1 = '^[^_]+(?=_)'; % Match what preceeds an underscore (section no).
    BAIdx = string;
    for iFile = 1:nFiles
        [~,fname,~] = fileparts( ...
            fullfile( finfo(iFile).folder,finfo(iFile).name )); 
        [startidx,endidx] = regexp( fname, expr1 ); % Section number.
        no = fname( startidx:endidx );
        BAIdx(iFile) = string( ['s',no] );
    end     
    BAIdx = unique( string(BAIdx) );
    nSecs = size(BAIdx,2);
    for iSec = 1:nSecs
        C.Dat.(BAIdx(iSec)) = struct;
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
            if isequal( BAIdx(iSec), string( ['s',no]) ) ...
                    && ismember( t, VALIDTARGETS )
                iBAIdx = num2str( BAIdx(iSec) );
                C.Dat.(iBAIdx).(t) = struct;
                C.Dat.(iBAIdx).(t).DatFile = fullfile( fdir, [fname,fext] );
            end
        end
    end

    % Parse data from files and normalize data from individual cryosections.
    for iSec = 1:nSecs
        T = fieldnames( C.Dat.(BAIdx{iSec}) );
        nTgts = size(T,1);
        for iTgt = 1:nTgts
            if ismember( T{iTgt}, VALIDTARGETS )
                C.Dat.(BAIdx{iSec}).(T{iTgt});
                d = delimread( ...
                    C.Dat.(BAIdx{iSec}).(T{iTgt}).DatFile,',','mixed');
                C.Dat.(BAIdx{iSec}).RawRadPsn = cat( 1, d.mixed{3:end,1} ); %%% This rewrites several times
                C.Dat.(BAIdx{iSec}).RadLen = max( C.Dat.(BAIdx{iSec}).RawRadPsn ); %%% So does this.
                assert(C.Dat.(BAIdx{iSec}).RadLen < 1000,'Invalid length.');
                    % Catches error if distance mistakenly is not converted
                    % from points to microns. All radial sections should be
                    % less than 1000 microns.
                A = d.mixed(3:end,2:end); % Index data within cell array.
                A = cell2mat(A);
                
                % If image is 8-bit, scale to 16-bit.
                maxVal = max(max(A));
                minVal = min(min(A));
                
                %%% NORMALIZE INDIVIDUAL CRYOSECTIONS
                %%% Scale each z-plane to the brightest for the cryosection.

                %TESTNORMALIZATION>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%                 figure
%                 subplot(1,3,1)
%                 plot(A,'LineStyle',':')
%                 hold on,plot(mean(A,2),'LineWidth',2,'LineStyle','-')
%                 
%                 toc
%                 lo = minVal/maxVal;
% %                 A = normalize(A,'range',[lo,1]);
%                 A = chi_sq_norm(A);
%                 m = max(max(A));
%                 A = A + maxVal - m;
% %                 A = A*maxVal;
%                 subplot(1,3,2)
%                 plot(A,'LineStyle',':')
%                 hold on,plot(mean(A,2),'LineWidth',2,'LineStyle','-')
                
                %%%%
                if maxVal < 256
                    A = A*256;
                end
%                 
%                 subplot(1,3,3)
%                 plot(A,'LineStyle',':')
%                 hold on,plot(mean(A,2),'LineWidth',2,'LineStyle','-')
                %TESTNORMALIZATION<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                assert(maxVal < 65536,'Invalid bit depth.');
                 
                C.Dat.(BAIdx{iSec}).(T{iTgt}).RawDat = A;
            end
        end
        C.Dat.(BAIdx{iSec}).RadPsn = ...
            uniformsample( C.Dat.(BAIdx{iSec}).RawRadPsn );
    end
        
    

    % Shift all raw data, anchoring to aligned pSmad peaks.
    % Calculate statistics on aligned data.
    for iSec = 1:nSecs
        x = C.Dat.(BAIdx{iSec}).RawRadPsn;
        %EDIT>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        % Determine pSmad peak offset from an arbitrary anchor point.
        %%% Change to align center of mass for top ~30%.
        %%% Add ability to align based on Sox2 peaks and on midpoint
        %%% between pSmad/Sox2.
        
        %%% Modularize using alignpeaks function.
        RawDat = struct; % Inverts from *.(Target).RawDat to RawDat.(Target)
        T = fieldnames( C.Dat.(BAIdx{iSec}) );
        nTgts = size(T,1);
        for iTgt = 1:nTgts
        
            if ismember( T{iTgt}, VALIDTARGETS ) % Need to skip RadPsn, etc.
            
                disp(T{iTgt})
                RawDat.(T{iTgt}) = C.Dat.(BAIdx{iSec}).(T{iTgt}).RawDat;
%                 yMat = C.Dat.(BAIdx{iSec}).(T{iTgt}).RawDat;
                
                mode = 'pSmad'; % Signal on which alignment is based.
                                % Options: 'mid','pSmad','Sox2'
                PERCENTILE = 1/3; % Percentile above which to consider a peak.
                [alRawDat,alSmDat] = alignpeaks(RawDat,x,mode,PERCENTILE);
                
%                 nZ = size(yMat,2);
%                 C.Dat.(BAIdx{iSec}).(T{iTgt}).AlgnDat = zeros(size(yMat));
%                 AlgnDatTmp = zeros( size(yMat) );
%                 for iZ = 1:nZ
%                     AlgnDatTmp(:,iZ) = ...
%                         circshift( yMat(:,iZ), round(shiftIdx(iZ)), 1 );
            end
                
        end

    end
        
        %EDIT<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        %REPLACE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        yMat = C.Dat.(BAIdx{iSec}).pSmad.RawDat;
        [nPts,nZ] = size(yMat);
        yMatSm = smoothdata( yMat );
        [yMatSmMax,idxOrigin] = max(yMatSm);
%         ANCHOR = 2/3;
        
%         PERCENTILE = 0.33;
        thresh = (1 - PERCENTILE)*yMatSmMax;
        peakRegions = cell(1,nZ);
        
        idx0 = zeros(1,nZ);
        idx1 = zeros(1,nZ);
        for iZ = 1:nZ
            % Search along the signal for the region that rises above the
            % threshold.
            for iPt = 1:nPts
                if yMatSm(iPt,iZ) > thresh(iZ) 
                    if numel(peakRegions{iZ}) == 0
                        idx0(iZ) = iPt;
                    end
                 peakRegions{iZ} = [peakRegions{iZ};yMatSm(iPt,iZ)];
                end
            end
            idx1(iZ) = idx0(iZ) + numel(peakRegions{iZ});
        end
        
        idx = cat(3,idx0,idx1);
       
        idx = mean(idx,3);
        
        clear yMatSm
        
        peakAlignAnchor = round( ANCHOR*size(x,1) );
        shiftIdx = peakAlignAnchor - idx;
        %REPLACE<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        % Shift data to align associated pSmad peaks and calculate stats.
        for iTgt = 1:nTgts
            if ismember( T{iTgt}, VALIDTARGETS ) % Need to skip RadPsn, etc.
                %REPLACE>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                disp(T{iTgt})
                yMat = C.Dat.(BAIdx{iSec}).(T{iTgt}).RawDat;
                nZ = size(yMat,2);
                C.Dat.(BAIdx{iSec}).(T{iTgt}).AlgnDat = zeros(size(yMat));
                AlgnDatTmp = zeros( size(yMat) );
                for iZ = 1:nZ
                    AlgnDatTmp(:,iZ) = ...
                        circshift( yMat(:,iZ), round(shiftIdx(iZ)), 1 );
                end
                %REPLACE<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                % Sample mean over z-planes.
                MnDatTmp = mean(AlgnDatTmp,2);               
                % Bin data to be equal size across all sections and all
                % cochleae.
                C.Dat.(BAIdx{iSec}).(T{iTgt}).AlgnDat = ...
                    uniformsample( AlgnDatTmp );
                C.Dat.(BAIdx{iSec}).(T{iTgt}).MnDat = ...
                    uniformsample( MnDatTmp );
                % Sample standard deviation.
                WEIGHT = 0;
                C.Dat.(BAIdx{iSec}).(T{iTgt}).STDDat = ...
                    std( C.Dat.(BAIdx{iSec}).(T{iTgt}).AlgnDat, WEIGHT, 2);
                % Sample standard error of the mean.
                % Note: Underestimates population error with low n.
                C.Dat.(BAIdx{iSec}).(T{iTgt}).SEMDat = ...
                    (1/sqrt(nZ))*C.Dat.(BAIdx{iSec}).(T{iTgt}).STDDat;
                
                % Smooth the data.
                C.Dat.(BAIdx{iSec}).(T{iTgt}).smAlgnDat = ...
                    smoothdata( C.Dat.(BAIdx{iSec}).(T{iTgt}).AlgnDat );
                C.Dat.(BAIdx{iSec}).(T{iTgt}).smMnDat = ...
                    smoothdata( C.Dat.(BAIdx{iSec}).(T{iTgt}).MnDat );
                C.Dat.(BAIdx{iSec}).(T{iTgt}).smSTDDat = ...
                    std ( C.Dat.(BAIdx{iSec}).(T{iTgt}).smAlgnDat, WEIGHT, 2 );
                C.Dat.(BAIdx{iSec}).(T{iTgt}).smSEMDat = ...
                    (1/sqrt(nZ))*C.Dat.(BAIdx{iSec}).(T{iTgt}).smSTDDat;
                
            end % end if

        end % end Tgt loop

    end % end Sec loop
    toc(1)
end

%% Individual property set methods




end
end