% Cochlea data must be loaded into workspace.

nCoch = numel(C);
VALIDTARGETS = ["pSmad","Sox2","TOPRO3"];  
winSizes = 10:10:1000;
winSizesMicrons = winSizes./3.2073; % 3.2073 pixels/um
nWins = numel(winSizes);

% for iCoch = 1:nCoch
%     coch = C{iCoch};
%     coch = C{14};
    coch = C{12};
    S = fieldnames(coch.Dat); % Section names
    nSecs = numel(S);
    
    for iSec = 1:nSecs
        disp(['Section ',S{iSec},' (',num2str(iSec),'/',num2str(nSecs),')'])
        figure
        lineColors = jet(nWins);
        colormap(lineColors)
        circPsn = coch.Dat.(S{iSec}).OSR.circPsn;
        
        Ttemp = fieldnames( coch.Dat.(S{iSec}).OSR );
        nFields = size( Ttemp, 1);
        T = {};
        for iField = 1:nFields
            if ismember ( Ttemp{iField}, VALIDTARGETS )
                T = [ T, Ttemp{iField} ];
            end
        end
        nTgts = numel(T);
        for iTgt = 1:nTgts
            RawDat.(T{iTgt}) = ...
                maxintproj( coch.Dat.(S{iSec}).OSR.(T{iTgt}).rawDat );
        end
        
        SmDatMovmean = cell(nWins,1);
        SmDatSgolay = cell(nWins,1);
        SmDatLoess = cell(nWins,1);
        for iWin = 1:nWins
            SmDatMovmean{iWin} = ...
                smoothrawdata(RawDat, circPsn, 'movmean', winSizes(iWin));
            SmDatSgolay{iWin} = ...
                smoothrawdata(RawDat, circPsn, 'sgolay', winSizes(iWin));
            SmDatLoess{iWin} = ...
                smoothrawdata(RawDat, circPsn, 'loess', winSizes(iWin));
        end
        
        MovmeanErr = struct;
        SgolayErr = struct;
        LoessErr = struct;
        SecDerMovmeanErr = struct;
        SecDerSgolayErr = struct;
        SecDerLoessErr = struct;
        for iTgt = 1:nTgts
            for iWin = 1:nWins
                MovmeanErr.(T{iTgt})(iWin) = ...
                    sqrt(immse(SmDatMovmean{iWin}.(T{iTgt}), RawDat.(T{iTgt}) ));
                SgolayErr.(T{iTgt})(iWin) = ...
                    sqrt(immse(SmDatSgolay{iWin}.(T{iTgt}), RawDat.(T{iTgt}) ));
                LoessErr.(T{iTgt})(iWin) = ...
                    sqrt(immse(SmDatLoess{iWin}.(T{iTgt}), RawDat.(T{iTgt}) ));
            end
            % Numerically approximate error derivitives
            FirstDerMovmeanErr.(T{iTgt}) = ...
                diff( MovmeanErr.(T{iTgt}), 1 );
            FirstDerSgolayErr.(T{iTgt}) = ...
                diff( SgolayErr.(T{iTgt}), 1 );
            FirstDerLoessErr.(T{iTgt}) = ...
                diff( LoessErr.(T{iTgt}), 1 );

            SecDerMovmeanErr.(T{iTgt}) = ...
                diff( MovmeanErr.(T{iTgt}), 2 );
            SecDerSgolayErr.(T{iTgt}) = ...
                diff( SgolayErr.(T{iTgt}), 2 );
            SecDerLoessErr.(T{iTgt}) = ...
                diff( LoessErr.(T{iTgt}), 2 );
        end

        %% Plot results.
        % subplot offsets
        for iTgt = 1:nTgts
            switch iTgt
                case 1
                    spPsn = 0;
                case 2
                    spPsn = 3;
                case 3
                    spPsn = 6;
            end
            %% Plot smoothing results
            for iWin = 1:nWins                
                % movmean
                subplot(nTgts,4,iTgt + spPsn)
                plot(circPsn, SmDatMovmean{iWin}.(T{iTgt}),'Color',lineColors(iWin,:),'LineWidth',1)
                set(gca,'clim',winSizesMicrons([1,end]));
                cbar = colorbar;
                cbar.Label.String = 'Smoothing Window Size [\mum]';
                hold on
                % sgolay
                subplot(nTgts,4,iTgt + 1 + spPsn)
                plot(circPsn, SmDatSgolay{iWin}.(T{iTgt}),'Color',lineColors(iWin,:),'LineWidth',1)
                set(gca,'clim',winSizesMicrons([1,end]));
                cbar = colorbar;
                cbar.Label.String = 'Smoothing Window Size [\mum]';
                hold on
                % loess
                subplot(nTgts,4,iTgt + 2 + spPsn)
                plot(circPsn, SmDatLoess{iWin}.(T{iTgt}),'Color',lineColors(iWin,:),'LineWidth',1)
                set(gca,'clim',winSizesMicrons([1,end]));
                cbar = colorbar;
                cbar.Label.String = 'Smoothing Window Size [\mum]';
                hold on
            end
            %% Overlay smooth data with raw data
            % movmean
            subplot(nTgts,4,iTgt + spPsn)
            plot(circPsn, RawDat.(T{iTgt}),'Color','k','LineStyle',':')
            xlim([0,max(circPsn)])
            ylim([0,max(max(RawDat.(T{iTgt})))])
            xlabel('\mum')
            ylabel('Fluo.')
            title(['movmean ',T{iTgt}])
            % sgolay
            subplot(nTgts,4,iTgt + 1 + spPsn)
            plot(circPsn, RawDat.(T{iTgt}),'Color','k','LineStyle',':')
            xlim([0,max(circPsn)])
            ylim([0,max(max(RawDat.(T{iTgt})))])
            xlabel('\mum')
            ylabel('Fluo.')
            title(['sgolay ',T{iTgt}])
            % loess
            subplot(nTgts,4,iTgt + 2 + spPsn)
            plot(circPsn, RawDat.(T{iTgt}),'Color','k','LineStyle',':')
            xlim([0,max(circPsn)])
            ylim([0,max(max(RawDat.(T{iTgt})))])
            xlabel('\mum')
            ylabel('Fluo.')
            title(['loess ',T{iTgt}])
            
            %% Plot errors
            % Get y-axis limits
            maxErrList = zeros(nTgts,1);
            for iTgtTmp = 1:nTgts
                maxErrList(iTgtTmp) = ...
                    max(max( [MovmeanErr.(T{iTgtTmp}), SgolayErr.(T{iTgtTmp}), LoessErr.(T{iTgtTmp})] ));
            end
            maxErr = max(maxErrList);
            
            minD1ErrList = zeros(nTgts,1);
            maxD1ErrList = zeros(nTgts,1);
            
            minD2ErrList = zeros(nTgts,1);
            maxD2ErrList = zeros(nTgts,1);
            for iTgtTmp = 1:nTgts
                minD1ErrList(iTgtTmp) = ...
                    min(min( [FirstDerMovmeanErr.(T{iTgtTmp}), FirstDerSgolayErr.(T{iTgtTmp}), FirstDerLoessErr.(T{iTgt})] ));
                maxD1ErrList(iTgtTmp) = ...
                    max(max( [FirstDerMovmeanErr.(T{iTgtTmp}), FirstDerSgolayErr.(T{iTgtTmp}), FirstDerLoessErr.(T{iTgt})] ));
                minD2ErrList(iTgtTmp) = ...
                    min(min( [SecDerMovmeanErr.(T{iTgtTmp}), SecDerSgolayErr.(T{iTgtTmp}), SecDerLoessErr.(T{iTgt})] ));
                maxD2ErrList(iTgtTmp) = ...
                    max(max( [SecDerMovmeanErr.(T{iTgtTmp}), SecDerSgolayErr.(T{iTgtTmp}), SecDerLoessErr.(T{iTgt})] ));
            end
            mind2Err = min(minD2ErrList);
            maxd2Err = max(maxD2ErrList);
            %% movmean 
            subplot(nTgts,4,iTgt + 3 + spPsn)
%             plot(MovmeanErr.(T{iTgt})(1:end-1),FirstDerMovmeanErr.(T{iTgt}),'r','LineStyle','-','Marker','.','MarkerSize',8,'LineWidth',1)
            plot(winSizesMicrons,MovmeanErr.(T{iTgt}),'r','LineStyle','-','LineWidth',1)
%             yyaxis left
%             plot(winSizesMicrons, MovmeanErr.(T{iTgt}),'r','LineStyle','-','Marker','.','MarkerSize',8,'LineWidth',1)
%             ylim([0, maxErr]) 
            xlabel('Window Size')
            ylabel('RMSE')
%             yyaxis right
%             plot(winSizesMicrons(1:end-2), SecDerMovmeanErr.(T{iTgt}),'Color','r','Marker','+')
%             plot(winSizesMicrons(1:end-1), SlopeMovmeanErr.(T{iTgt}),'Color','r','Marker','o')
%             ylim([mind2Err, maxd2Err]);
%             ylabel('d^2RMSE/dwin^2 (-+-)');
            title([S{iSec},' ',T{iTgt}])
            grid on
            hold on
            %% sgolay
            subplot(nTgts,4,iTgt + 3 + spPsn)
%             plot(SgolayErr.(T{iTgt})(1:end-1),FirstDerSgolayErr.(T{iTgt}),'g','LineStyle','-','Marker','.','MarkerSize',8,'LineWidth',1)
            plot(winSizesMicrons,SgolayErr.(T{iTgt}),'g','LineStyle','-','LineWidth',1)
%             yyaxis left
%             plot(winSizesMicrons, SgolayErr.(T{iTgt}),'g','LineStyle','-','Marker','.','MarkerSize',8,'LineWidth',1)
%             ylim([0, maxErr]) 
            xlabel('Window Size')
            ylabel('RMSE')
%             yyaxis right
%             plot(winSizesMicrons(1:end-2), SecDerSgolayErr.(T{iTgt}),'Color','g','Marker','+')
%             plot(winSizesMicrons(1:end-1), SlopeSgolayErr.(T{iTgt}),'Color','g','Marker','o')
%             ylim([mind2Err, maxd2Err]);
%             ylabel('d^2RMSE/dwin^2 (-+-)');
            title([S{iSec},' ',T{iTgt}])
            grid on
            hold on
            %% loess
            subplot(nTgts,4,iTgt + 3 + spPsn)
%             plot(LoessErr.(T{iTgt})(1:end-1),FirstDerLoessErr.(T{iTgt}),'b','LineStyle','-','Marker','.','MarkerSize',8,'LineWidth',1)
            plot(winSizesMicrons,LoessErr.(T{iTgt}),'b','LineStyle','-','LineWidth',1)
%             yyaxis left
%             plot(winSizesMicrons, LoessErr.(T{iTgt}),'b','LineStyle','-','Marker','.','MarkerSize',8,'LineWidth',1)
%             ylim([0, maxErr]) 
            xlabel('Window Size')
            ylabel('RMSE')
%             yyaxis right
%             plot(winSizesMicrons(1:end-2), SecDerLoessErr.(T{iTgt}),'Color','b','Marker','+')
%             plot(winSizesMicrons(1:end-1), SlopeLoessErr.(T{iTgt}),'Color','b','Marker','o')
%             ylim([mind2Err, maxd2Err]);
%             ylabel('d^2RMSE/dwin^2 (-+-)');
            title([S{iSec},' ',T{iTgt}])
            grid on
            hold on
            
            legend('movmean','sgolay','loess','Location','best')
%             xlabel('Window size [\mum]')

        end
        %% Calculate PI with window size
        % Discretize variables.
        figure
        circPsnDisc = discretize(circPsn,numel(circPsn));
        bitsMovmean = struct;
        bitsSgolay = struct;
        bitsLoess = struct;
        for iTgt = 1:nTgts
            iTgt = 2;
            for iWin = 1:nWins
                nPts = numel( SmDatMovmean{iWin}.(T{iTgt}) );
                signalMovmeanDisc = discretize(SmDatMovmean{iWin}.(T{iTgt}), nPts);
                signalSgolayDisc = discretize(SmDatSgolay{iWin}.(T{iTgt}), nPts);
                signalLoessDisc = discretize(SmDatLoess{iWin}.(T{iTgt}), nPts);
                bitsMovmean.(T{iTgt})(iWin) = mutInfo(circPsnDisc, signalMovmeanDisc);
                bitsSgolay.(T{iTgt})(iWin) = mutInfo(circPsnDisc, signalSgolayDisc);
                bitsLoess.(T{iTgt})(iWin) = mutInfo(circPsnDisc, signalLoessDisc);
            end
            %% movmean
            subplot(1,3,1)
            plot(winSizes, bitsMovmean.(T{iTgt}))
            xlabel('Window size [\mum]')
            ylabel('Positional information [bits]')
            hold on
            %% sgolay
            subplot(1,3,2)
            plot(winSizes, bitsSgolay.(T{iTgt}))
            xlabel('Window size [\mum]')
            ylabel('Positional information [bits]')
            hold on
            %% loess
            subplot(1,3,3)
            plot(winSizes, bitsLoess.(T{iTgt}))
            xlabel('Window size [\mum]')
            ylabel('Positional information [bits]')
            hold on
        end
        
        %% Identify window size cutoff
        
        
    end
% end
