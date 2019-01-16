%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   File Name:      'lininterp.m'
%   Creator:        Matthew J. Thomposn
%   Date:           2018-01-25
%   Objective:       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; clc;

% Load Excel file containing smoothed data for all experimental samples
% under a single experimental condition (replicates) with each replicate as
% a separate sheet.
currentFolder = pwd;
[fileName,pathName] = uigetfile('*.xlsx;*.xls', ...                        
    'Select the Excel file containing the raw data to analyze.');
source = [pathName fileName];
[status,sheetNameArray] = xlsfinfo(source);
copyfile(source,currentFolder); % Temp copy in current directory.

RES = 0.01; % Resolution for interpolation between data points.
PREC = numel(num2str(RES)) - 2; % Precision: sig figs

% Count number of replicates.
nSheets= size(sheetNameArray,2); 
nReplicates = nSheets/2;

% Initialize arrays and values.
xArray = [];
xPos = 0;
yArray = [];
xConsArray = [];
yMatrix = [];
yListLocal = [];

% Iterate over replicates.
for i = (nReplicates + 1):nSheets
    sheetName = char(sheetNameArray(i));
    sheetDataMatrix = xlsread(fileName,i); % Column vectors for x and y data.
    dataSize = size(sheetDataMatrix); % Dimensions of sheetDataMatrix
    lastDataPointIndex = dataSize(1);
    % Iterate over data points in a sheet.
    for j = 1:(lastDataPointIndex - 1)
        % Determine (x0,y0).
        x0 = round(sheetDataMatrix(j,1),PREC);
        y0 = round(sheetDataMatrix(j,2),PREC);
        data0 = [round(sheetDataMatrix(j,1),PREC), ...
            round(sheetDataMatrix(j,2),PREC)]
        
        % Record the first data point.
        if j == 1           
            xArray = [xArray,x0];
            yArray = [yArray,y0];
        end
        
        % Determin (x1,y1).
        x1 = round(sheetDataMatrix(j+1,1),PREC);
        y1 = round(sheetDataMatrix(j+1,2),PREC);
        data1 = [round(sheetDataMatrix(j+1,1),PREC), ...
            round(sheetDataMatrix(j+1,2),PREC)]
        % Record each data point up to but not including (x1,y1).
        if x0 ~= x1
            xArray = [xArray,x0];
            yArray = [yArray,y0];
        end
          
        nInterpPoints = (x1 - x0)/RES; % Num of pts to interp between data pts.
        
        % Iterate over number of resolution steps between data points.
        % Interpolate between data points.
        if x0 ~= x1
            % If neighboring x positions DO NOT round to the same values,
            % run interpolation.
            for k = 1:(nInterpPoints - 1)
                xPosInterp = x0 + k*RES;
                yValInterp = y0 + ...
                    (xPosInterp - x0)*(y1 - y0)/(x1 - x0);
                xArray = [xArray,xPosIterp];
                yArray = [yArray,yValInterp];
            end
            if numel(yListLocal) > 0 
                yLocalAvg = mean (yListLocal);
                yArray(numel(yArray)) = yLocalAvg;
                yListLocal = []; %Restart list of y values to average.
            end
        else
            % If neighboring x positions DO round to the same value, gather
            % y values at this position to average.
            yListLocal = [yListLocal,y0];
        end 

                
    end % for (line 39)
%     NEED TO ADD FINAL DATA POINT...MATLAB NOT ALLOWING FOR SOME REASON
%     x_array = [x_array,sheet_data(j,1);
%     y_array = [y_array,sheet_data(j,2);
    
    % Plot interpolated points with data.
    plot(xArray,yArray)

    % Write new interpolated data to new sheets in Excel.
    interpSheet = strcat(sheetName,'_interp');
    interpData = [xArray',yArray'];
    xlswrite(fileName,interpData,interpSheet);
    
    %% --- Under construction ---
    % Consolidate data
    % xConsArray: consolidated array of all x/L points from all 
    % replicates, no duplicates
    % yMat: each row corresponds to a replicate. values align with
    % x/L as appropriate. n rows
    
    % Append 
    xConsArray = [xConsArray,x_array];
    
    % Ordered ist of indices for all unique values in x_cons_array
    [~,index] = unique(xConsArray,'first');
    
    % 
    
    % Update to unique sorted values only
    xConsArray = xConsArray(sort(index));
    
    % Find indices of x_cons_array for values that match values in x_array
    [~,indices] = ismember(x_array,xConsArray);
    
    if i == 1
        yMatrix = NaN(n,numel(x_array));
        yMatrix(1,:) = y_array;
    else
        % Add column of NaN to y_mat at newly added unique values to
        % x_cons_array
        
        
    end
    % Create a NaN matrix, size n x numel(x_cons_array)
    % Add NaN column to y_mat for each new unique x value added to
    % x_cons_array.
    % Add y_array values to corresponding x_array value indices
    % 
    
    %% Reset values.
    xArray = [];
    xPos = 0;
    yArray = [];
end

% Move temp Excel file to original directory and rename.
expr = '[^.]*';
f = regexp(fileName,expr,'match'); % Vector containing 2 elements: the file name and type with no period.
newfname = strcat(f(1),'_interp.',f(2)); % Add '_sm' to the file name.
dest = char(strcat(pathName,newfname));
oldfname = char(fileName);
status = movefile(fileName,dest)

% Calculate mean, std, and 95% CI at each x/L position, append as columns
% to data_cons matrix.

% Ignore NaN: mean(A(~isnan(A)));



