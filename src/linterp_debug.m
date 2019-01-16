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
xyOutputMatrix = [];
yListLocal = [];
replicatesMatrix = [];

% Iterate over replicates.
for i = (nReplicates + 1):nSheets
    
    %% Access Excel Sheet
    sheetName = char(sheetNameArray(i));
    sheetDataMatrix = xlsread(fileName,i); % Column vectors for x and y data.
    dataSize = size(sheetDataMatrix); % Dimensions of sheetDataMatrix
    lastDataPointIndex = dataSize(1);
    
    %% Iterate over data points in a sheet.
    for j = 1:(lastDataPointIndex - 1)
        %% Determine data points to interpolate between.
        % Determine (x0,y0) - the 'current' point.
        x0y0 = [round(sheetDataMatrix(j,1),PREC), ... % x0
            round(sheetDataMatrix(j,2),PREC)];        % y0
        
        % Record the first data point of the sheet.
        if j == 1
            xyOutputMatrix = [xyOutputMatrix; x0y0];
        end
        
        % Determine (x1,y1) - the 'next' point.
        x1y1 = [round(sheetDataMatrix(j+1,1),PREC), ... % x1
            round(sheetDataMatrix(j+1,2),PREC)];        % y1
        
        nInterpPoints = (x1y1(1) - x0y0(1))/RES; % Num of pts to interp between data pts.
        
        %% Interpolate and store data points + interpolated points in a matrix.        
        % Iterate over number of resolution steps between data points.
        if x0y0(1) ~= x1y1(1) % Usual: neigboring x-vals NOT rounded to be equal

            % Check if there is a list of y-values to average at a previous
            % x-postion repeatedly rounded to the same value.
            if numel(yListLocal) > 0 
                % True: current point (x0,y0) is the last on this list of 
                % repeated rounded x0 positions.
                yLocalAvg = round(mean(yListLocal),PREC);
                x0y0(2) = yLocalAvg;
                yListLocal = []; %Reset list of y-values to average.
            end

            % Append the new data point to the output matrix.
            xyOutputMatrix = [xyOutputMatrix; x0y0]; 
            
            % Run interpolation, stopping before the next data point.
            for k = 1:(nInterpPoints - 1)         
                % Formula: y = y0 + (x - x0)*(y1 - y0)/(x1 - x0);   
                xyInterp = x0y0 + ...
                    [k*RES, ...                                 % x
                    ((x0y0(1) + k*RES) - x0y0(1))* ...          % y
                    (x1y1(2) - x0y0(2))/(x1y1(1) - x0y0(1))];   % y (cont'd)
                
                % Append interpolated values to output matrix.
                xyOutputMatrix = [xyOutputMatrix; xyInterp];
            end
            

        else % Exception: neighboring x-vals DO round to same value.
            % Gather y values at this position to average.
            yListLocal = [yListLocal,x0y0(2)];
        end 

                
    end

    %% Append final data point.
    xyOutputMatrix = [xyOutputMatrix; sheetDataMatrix(lastDataPointIndex,:)];
    
    % Plot interpolated points with data.
    plot(xyOutputMatrix(:,1),xyOutputMatrix(:,2))
    
    % Append to master matrix for statistics and normalize signal data to
    % max replicate.
    switch i
        case (nReplicates + 1)
            replicatesMatrix = xyOutputMatrix;
        otherwise
            replicatesMatrix = [replicatesMatrix, xyOutputMatrix(:,2)];
    end
    
    if i == nSheets
        MAX = max(max(replicatesMatrix(:,(2:end))));
        replicatesMatrix = [replicatesMatrix(:,1),replicatesMatrix(:,(2:end))/MAX];    
    end
    
    % Write new interpolated data to new sheets in Excel.
    interpSheet = strcat(sheetName,'_interp');
    interpData = [xyOutputMatrix(:,1),xyOutputMatrix(:,2)];
    xlswrite(fileName,interpData,interpSheet);
    

    
    % Reset values for next Excel sheet replicate.
    xyOutputMatrix = [];
    yListLocal = [];
end

%% Move temp Excel file to original directory and rename.
expr = '[^.]*';
f = regexp(fileName,expr,'match'); % Vector containing 2 elements: the file name and type with no period.
newfname = strcat(f(1),'_interp.',f(2)); % Add '_sm' to the file name.
dest = char(strcat(pathName,newfname));
oldfname = char(fileName);
status = movefile(fileName,dest)

%% Calculate mean, std, and 95% CI at each x/L position, append as columns
% to data_cons matrix.

nPoints = size(replicatesMatrix,1);
meanArray = zeros(nPoints,1);
stdArray = zeros(nPoints,1);
zStar = 1.96;
lowerCiBound = zeros(nPoints,1);
upperCiBound = zeros(nPoints,1);
for i = 1:nPoints
    meanArray(i) = mean([replicatesMatrix(i,2:end)]);
    stdArray(i) = std([replicatesMatrix(i,2:end)]);
    lowerCiBound(i) = meanArray(i) - zStar*stdArray(i)/sqrt(3);
    upperCiBound(i) = meanArray(i) + zStar*stdArray(i)/sqrt(3);
end

%% Plot results
figure
% subplot(1,2,1)
hold on
ciplot(lowerCiBound,upperCiBound,replicatesMatrix(:,1))
plot(replicatesMatrix(:,1),meanArray,'k')
    t = [f(1),'Mean +/- 95% CI','n = 3']; % Update to have n = nReplicates
    title(t, 'interpreter', 'none')
    xlabel('x/L')
    ylabel('Intensity')
    xlim([0 1])
hold off

% subplot(1,2,2)
% hold on
% plot(replicatesMatrix(:,1),replicatesMatrix(:,2),'k')
% plot(replicatesMatrix(:,1),replicatesMatrix(:,3),'k')
% plot(replicatesMatrix(:,1),replicatesMatrix(:,4),'k')
%     t = [f(1) 'Raw Data','n = ',nReplicates]; 
%     title(t, 'interpreter', 'none')
%     xlabel('x/L')
%     ylabel('Intensity')
%     xlim([0 1])
% hold off

