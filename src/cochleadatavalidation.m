function[]=cochleadatavalidation()

%this function takes inputs of excel data sheets from morphogen
%concentration data from imagej and determines if the data is consitent
%between the different chanels, both in number of data points and scale of
%data points. This is useful for checking if an error has been made in data
%collection or if a pSmad dataset still needs conversion to micrometers
%after despeckling
%
%Mitchell McMahon
%2019-06-27


fdir = uigetdir;
cd(fdir);
files = dir(fullfile(fdir,'*.xlsx'));
nfiles = length(files);   


badCount = 0;
fprintf('files with different data lengths\n')
for ifile = 1:nfiles            %this for loop determines if a file has a length descrepency between two sheets
[fdir, fname, fext] = fileparts( ...
     fullfile( files(ifile).folder,files(ifile).name ) );
f = fullfile(fdir,[fname,fext]);

sNames = {'TOPRO3','Sox2','pSmad'};
nNames = numel(sNames);

    for iName = 1:nNames
        [~,~,raw] = xlsread(f,sNames{iName}); %reads data from excel sheet and converts to cell matrix
        sNames{iName} = raw;
    end
        if (size(sNames{1},1) == size(sNames{2},1)) && (size(sNames{2},1) == size(sNames{3},1))    %compare lengths of data       
            continue
        else          
            sNames = {'TOPRO3','Sox2','pSmad'};
            disp(f)         %displays file name of file with error
            badCount = badCount+1;
        end
        
end
  
fprintf('files that need scale conversion\n')
for ifile = 1:nfiles %this for loop determines if the x column measurements are consistent between sheets
[fdir, fname, fext] = fileparts( ...
     fullfile( files(ifile).folder,files(ifile).name ) );
f = fullfile(fdir,[fname,fext]);

sNames = {'TOPRO3','Sox2','pSmad'};
nNames = numel(sNames);

     for iName = 1:nNames
        [num,~,~] = xlsread(f,iName,'A3:A10');
        sNames{iName} = num;
   end
   N=cell2mat(sNames);

        if N(3,2) == N(3,3) %compares a data point between two sheets to see if they match(change to nth value)
            continue
        else
            sNames = {'TOPRO3','Sox2','pSmad'};
            disp(f);       %displays file name of file with error
            badCount = badCount+1;
        end
        
end        
        
    if badCount == 0
        fprintf('no error\n')  %if no errors detected, print no error
    end
end



