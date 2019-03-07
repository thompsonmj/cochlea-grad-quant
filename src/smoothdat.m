function yOut = smoothdat(yIn)
% SMOOTHDATA smooths data vertically and uniformly with constant parameters
% controlled here. Data must be arranged as column vectors.

    [nRow,nCol] = size(yIn);
    WFRAC = 0.1;
    w = round( WFRAC*nRow );
    yOut = zeros(nRow,nCol);
    for iCol = 1:nCol
            yOut(:,iCol) = fastsmooth (yIn(:,iCol),w );
    end

end