function ImageSmoothing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   File Name:      'ImageSmoothing.m'
%   Creator:        Alexander R. Ocken
%   Date:           2017-11-01
%   Modified by:    Matthew J. Thompson
%   Date:           2018-01-16
%   Adapted from:   'fastsmooth.m' T. C. O'Haver, 2008
%   Objective:      Develop a code that takes Image Line Profile data
%                   (generated from ImageJ and saved in Excel) from Excel
%                   and reduces the noise in the pixel intensity caused by
%                   the space between the cells. This function makes use of
%                   'fastsmooth.m' function that smooths the data using 
%                   pseudo-Gaussian (3 passes of sliding-average) 
%                   smoothing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; clc;

currentFolder = pwd;
% Only allow .xlsx and .xls files to be selected.
[FileName,PathName] = uigetfile('*.xlsx;*.xls', ...                        
    'Select the Excel file containing the raw data to analyze.');
source = [PathName FileName];
[status,sheets] = xlsfinfo(source); % status: desciption if load is successful, 0 if unsuccessful. sheets: cell array of strings containing sheet names
copyfile(source,currentFolder) % Create a temporary copy of the spreadsheet into the current directory for analysis.

num_sheets = size(sheets,2); % Count the number of sheets in the Excel file.
c = [17 17 17]; % Trying to get the raw data to be light grey.
for i = 1:num_sheets % Iterate over all sheets (channels).
    sheet = char(sheets(i)); % Convert sheet name from cell to character vector.
    data = xlsread(FileName,i); % Read raw data in sheet i.
    datasetSize = size(data); % Determine dataset size.
    numberOfImages = datasetSize(2)/2; % Determine the Number of Images.
    x = zeros(datasetSize(1),numberOfImages); % Allocate Memory.
    y = zeros(datasetSize(1),numberOfImages); % Allocate Memory.
    ySmooth = zeros(datasetSize(1),numberOfImages); % Allocate Memory.
    for n = 1:numberOfImages % For each image:
        x(:,n) = data(:,(n*2-1)); % extract X values to x matrix,
        x = x./max(x); 
        y(:,n) = data(:,(n*2)); % extract Y values to y matrix, and                                                        
        % y = y./max(y);
        ySmooth(:,n) = fastsmooth(transpose(y(:,n)),15,3,1); % smoothen the y data.
        % ySmooth = ySmooth./max(y);
    end
    %%%%%
    % Write smoothened channel data to Excel.
    %%%%%
    smoothsheet = strcat(sheet,'_sm'); % Smoothened Data Sheet in Excel.
    smoothdata = zeros(datasetSize); % Allocate Memory.
    for n = 1:numberOfImages % For each image:
        smoothdata(:,(n*2-1)) = x(:,n); % combine x values with
        smoothdata(:,(n*2)) = ySmooth(:,n); % smoothened y values.
    end
    xlswrite(FileName,smoothdata,smoothsheet); % Write smoothened data to Excel.
    
    %%%%%
    % Plot profiles of channel data.
    %%%%%
    figure(i);
    hold on
    for n = 1:numberOfImages
        subplot(numberOfImages,1,n);
        plot(x(:,n),y(:,n),'k-',x(:,n),ySmooth(:,n),'k-')
%         if n == 1
            t = strcat('Signal Intensity of',32,39,sheet,39);
            title(t,'interpreter','none'); % Disable underscore subscript in figure title.
%         elseif n == round(numberOfImages/2)
            ylabel('Intensity [normalized]')
%         elseif n == numberOfImages
            xlabel('Distance [normalized] (Lateral to Medial Domain)')
%         end
    end    
end

%%%%%
% Move new Excel file to original directory and rename.
%%%%%
expr = '[^.]*';
f = regexp(FileName,expr,'match'); % Vector containing 2 elements: the file name and type with no period.
newfname = strcat(f(1),'_sm.',f(2)); % Add '_sm' to the file name.
dest = char(strcat(PathName,newfname));
oldfname = char(FileName);
status = movefile(FileName,dest)

%% Example
% x=1:1000;
% for n=1:10
%     y1(n,:)=2.*gaussian(x,500,150)+whitenoise(x)
%     y2(n,:)=fastsmooth(y1(n,:),50,3);
% end
% exampleplot = figure(1);
% subplot(2,1,1)
% plot(x,y1)
% subplot(2,1,2)
% plot(x,y2)

% function g = gaussian(x,pos,wid)
% %  gaussian(x,pos,wid) = gaussian peak centered on pos, half-width=wid
% %  x may be scalar, vector, or matrix, pos and wid both scalar
% %  T. C. O'Haver, 1988
% % Examples: gaussian([0 1 2],1,2) gives result [0.5000    1.0000    0.5000]
% % plot(gaussian([1:100],50,20)) displays gaussian band centered at 50 with width 20.
% g = exp(-((x-pos)./(0.60056120439323.*wid)) .^2);

% function y=whitenoise(x);
% % Random noise with white power spectrum with mean zero 
% % and unit standard deviation, equal in length to x
% % Tom O'Haver, 2008
% y=randn(size(x));

function SmoothY = fastsmooth(Y,w,type,ends)
% fastbsmooth(Y,w,type,ends) smooths vector Y with smooth 
%  of width w. Version 2.0, May 2008.
% The argument "type" determines the smooth type:
%   If type=1, rectangular (sliding-average or boxcar) 
%   If type=2, triangular (2 passes of sliding-average)
%   If type=3, pseudo-Gaussian (3 passes of sliding-average)
% The argument "ends" controls how the "ends" of the signal 
% (the first w/2 points and the last w/2 points) are handled.
%   If ends=0, the ends are zero.  (In this mode the elapsed 
%     time is independent of the smooth width). The fastest.
%   If ends=1, the ends are smoothed with progressively 
%     smaller smooths the closer to the end. (In this mode the  
%     elapsed time increases with increasing smooth widths).
% fastsmooth(Y,w,type) smooths with ends=0.
% fastsmooth(Y,w) smooths with type=1 and ends=0.
% Example:
% fastsmooth([1 1 1 10 10 10 1 1 1 1],3)= [0 1 4 7 10 7 4 1 1 0]
% fastsmooth([1 1 1 10 10 10 1 1 1 1],3,1,1)= [1 1 4 7 10 7 4 1 1 1]
%  T. C. O'Haver, 2008.
    if nargin == 2, ends = 0; type = 1; end
    if nargin == 3, ends = 0; end
      switch type
        case 1
           SmoothY = sa(Y,w,ends);
        case 2   
           SmoothY = sa(sa(Y,w,ends),w,ends);
        case 3
           SmoothY = sa(sa(sa(Y,w,ends),w,ends),w,ends);
    end

function SmoothY = sa(Y,smoothwidth,ends)
    w = round(smoothwidth);
    SumPoints = sum(Y(1:w));
    s = zeros(size(Y));
    halfw = round(w/2);
    L = length(Y);
    for k = 1:L-w,
       s(k+halfw-1) = SumPoints;
       SumPoints = SumPoints-Y(k);
       SumPoints = SumPoints+Y(k+w);
    end
    s(k+halfw) = sum(Y(L-w+1:L));
    SmoothY = s./w;
    % Taper the ends of the signal if ends=1.
      if ends == 1,
      startpoint = (smoothwidth + 1)/2;
      SmoothY(1) = (Y(1)+Y(2))./2;
      for k=2:startpoint,
         SmoothY(k) = mean(Y(1:(2*k-1)));
         SmoothY(L-k+1) = mean(Y(L-2*k+2:L));
      end
    SmoothY(L) = (Y(L)+Y(L-1))./2;
 end