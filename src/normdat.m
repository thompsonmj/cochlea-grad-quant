function normOutput = normdat(profileSet)

%%%	use sparse matrix for inversion in the chi^2 norm code. 
%%% not sure if sparse already used

[nPts, nProfiles] = size(profileSet);
                  
% Rescales data to [0,1] interval
xScaled = (0:1/(nPts-1):1)';
profileRawMatrix = zeros(nPts, nProfiles);
profileExtrMatrix = zeros(nPts, nProfiles);
profileExtrMatrix2 = zeros(nPts, nProfiles);
profileIntMatrix = zeros(nPts, nProfiles);

idx = 1;

% Specific call to normalization algorithms
for i = 1:nProfiles
    Data(:,i) = profileSet(:,i);
end

% Normalization    
 for j = 1:nProfiles   
    profileRawMatrix(:,j) = Data(:,j);
    profileExtrMatrix(:,j) = extremanorm(Data(:,j));
    profileExtrMatrix2(:,j) = extremanorm2(Data(:,j));
    profileIntMatrix(:,j) = integral_norm(Data(:,j));
end
        
% Minimizing Error Normalization
chiSqNormProfile = chisqnorm(Data);
size(chiSqNormProfile)

% Statistical operations on output
%%%mean_dpp_raw = mean(dpp_matrix')';
%%%    min_temp = min(mean_dpp_raw);
%%%    max_temp = max(mean_dpp_raw);
%%%mean_dpp_raw = (mean_dpp_raw-min_temp)/(max_temp-min_temp);
%%%dpp_matrix = (dpp_matrix-min_temp)/(max_temp-min_temp);
%%%std_dpp_raw = std(dpp_matrix')';

meanProfileRaw = mean(profileRawMatrix')';
%     minTemp = min(meanProfileRaw);
%     maxTemp = max(meanProfileRaw);
% meanProfileRaw = (meanProfileRaw-minTemp)/(maxTemp-minTemp);
% profileRawMatrix = (profileRawMatrix-minTemp)/(maxTemp-minTemp);
% stdProfileRaw = std(profileRawMatrix')';

meanProfileExt = mean(profileExtrMatrix')';
    minTemp = min(meanProfileExt);
    maxTemp = max(meanProfileExt);
meanProfileExt = (meanProfileExt-minTemp)/(maxTemp-minTemp);
profileExtrMatrix = (profileExtrMatrix-minTemp)/(maxTemp-minTemp);
stdProfileExt = std(profileExtrMatrix')';

meanProfileExt2 = mean(profileExtrMatrix2')';
    minTemp = min(meanProfileExt2);
    maxTemp = max(meanProfileExt2);
meanProfileExt2 = (meanProfileExt2-minTemp)/(maxTemp-minTemp);
profileExtrMatrix2 = (profileExtrMatrix2-minTemp)/(maxTemp-minTemp);
stdProfileExt2 = std(profileExtrMatrix2')';

meanProfileInt = mean(profileIntMatrix')';
    minTemp = min(meanProfileInt);
    maxTemp = max(meanProfileInt);
meanProfileInt = (meanProfileInt-minTemp)/(maxTemp-minTemp);
profileIntMatrix = (profileIntMatrix-minTemp)/(maxTemp-minTemp);
stdProfileInt = std(profileIntMatrix')';

%%%ORIGINAL>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
% meanProfileChi = mean(chi2NormProfile')';
%     minTemp = min(meanProfileChi);
%     maxTemp = max(meanProfileChi);
% meanProfileChi = (meanProfileChi-minTemp)/(maxTemp-minTemp);
% % chi2NormProfile = (chi2NormProfile-minTemp)/(maxTemp-minTemp);
%%%ORIGINAL<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

%%%NEW>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
meanProfileChi = mean(chiSqNormProfile')';
    minRawTemp = min(meanProfileRaw);
    maxRawTemp = max(meanProfileRaw);
    minNormTemp = min(meanProfileChi);
    maxNormTemp = max(meanProfileChi);
% meanProfileChi = (meanProfileChi-minTemp)/(maxTemp-minTemp);
% % chiSqNormProfile = (chi2NormProfile-minTemp)/(maxTemp-minTemp);
% %                                     ^ moves min to 0  ^ makes overall range 1 
% chiSqNormProfile = (chiSqNormProfile)/(maxTemp-minTemp);
% chiSqNormProfile = chiSqNormProfile + abs(min(mean(chiSqNormProfile')')) + ...
%     abs(min(mean(profileRawMatrix')'));

chiSqNormProfile = ( chiSqNormProfile + abs(min(mean(chiSqNormProfile')')) + ...
    abs(min(mean(profileRawMatrix')')) ) * ...
    (maxRawTemp-minRawTemp)/(maxNormTemp-minNormTemp);

%%%NEW<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


stdProfileChi = std(chiSqNormProfile')';

%%%NormOutput_DMU.initial = dpp_matrix;

% figure
% plot(profileRawMatrix)
% title('Input Data');
% xlabel('Circumferencial Position');
% ylabel('Concentration(relative)');
% ylim([0 max(ylim)])
% NormOutput.raw = profileRawMatrix;
% saveas(gcf, 'Original input data.jpg')
% 
% figure
% plot(chi2NormProfile)
% title('Output Data by Minimizing Error');
% xlabel('Circumferencial Position');
% ylabel('Concentration(relative)');
% ylim([0 max(ylim)])
% saveas(gcf, 'Original output by minimizing error.jpg')
normOutput.chiSq = chiSqNormProfile;
%     
% figure
% plot(profileExtrMatrix)
% title('Output Data by Pinning Extremes');
% xlabel('Circumferencial Position');
% ylabel('Concentration(relative)');
% ylim([0 max(ylim)])
% saveas(gcf, 'Original output by pinning extremes.jpg')
% NormOutput.ext = profileExtrMatrix;
% 
% figure
% plot(profileExtrMatrix2)
% title('Output Data by Pinning Extremes');
% xlabel('Circumferencial Position');
% ylabel('Concentration(relative)');
% ylim([0 max(ylim)])
% saveas(gcf, 'Original output by pinning extremes.jpg')
% NormOutput.ext2 = profileExtrMatrix2;
% 
% figure
% plot(profileIntMatrix)
% title('Output Data by Integral Nomalization');
% xlabel('Circumferencial Position');
% ylabel('Concentration(relative)');
% ylim([0 max(ylim)])
% saveas(gcf, 'Original output by integral.jpg')
% NormOutput.int = profileIntMatrix;
% normOutput = NormOutput;
% save NormOutput8DMU_test.mat normOutput
end

%% Function for calculation of pinning extremes normalization

function [normOut] = extremanorm(I_vector)

[s1,s2] = size(I_vector); 
 
xy_ascending_y = sortrows(I_vector, 1); 
xy_descending_y = sortrows(I_vector,-1);

min = sum(xy_ascending_y(1:1,1))/1;  
max = sum(xy_descending_y(1:1,1))/1;

% normalization of intensity (max->1 min ->0)

xy_ascending_x = I_vector;

for i=1:s1
%     if(max <= xy_ascending_x(i,1)) 
%         xy_ascending_x(i,1) = 1 ; 
%     elseif(min >= xy_ascending_x(i,1))
%         xy_ascending_x(i,1) = 0 ; 
%     else
        xy_ascending_x(i,1) = (xy_ascending_x(i,1)-min)/(max-min);  
%     end    
end
normOut = xy_ascending_x;

end


%% Function for AP max and min reset
function [normOut] = extremanorm2(I_vector)

[s1,s2] = size(I_vector); 
 
xy_ascending_y = sortrows(I_vector, 1); 
xy_descending_y = sortrows(I_vector,-1);


min = sum(xy_ascending_y(1:1,1))/1;  
max = sum(xy_descending_y(1:1,1))/1;

% normalization of intensity (max->1 min ->0)

xy_ascending_x = I_vector;

for i=1:s1
%     if(max <= xy_ascending_x(i,1)) 
%         xy_ascending_x(i,1) = 1 ; 
%     elseif(min >= xy_ascending_x(i,1))
%         xy_ascending_x(i,1) = 0 ; 
%     else
        xy_ascending_x(i,1) = (xy_ascending_x(i,1))/(max) ;  
%     end    
end
normOut = xy_ascending_x;

end

%% Function for calculation of integral normalization
function norm_data = integral_norm(data_in)

    C2_L=data_in;
    integC2_L=trapz(C2_L);    
    norm_data=C2_L/(integC2_L);
    
end

%% Functions for minimiziation of squarred-error
function C_out = chisqnorm(I)

nProfiles = size(I,2);
% %Initialize Coef (A,B) matrix with intial values

Coef0 = ones(1,nProfiles);

% %Coef0(2,:) = -sum(I,1)/size(I,1);
options = optimset('TolFun',1e-6, 'Display', 'off');
warning('Off', 'optim:fmincon:SwitchingToMediumScale')

% %Generate anonymous function to pass multiple parameters to Resid

% %Call minimization routine to solve f (Resid)
% %LBound = zeros(2,size(I(1,:),2));
B = mean(I,1);
C_mean0= mean((I - ones(size(I,1),1)*B),2);
onemat = ones(size(I,1),1);
%%%c_err0 = 1e-4; 
c_err0 = 1e-4;
C_ERR0 = 1e-4;
c_err = 51;
c_err_min = 100;

lb = 0;
ub = 51;

nAttempts = 0;
threshIterator = 1;
disp('Starting optimization.')
disp(['Initial error threshold: ',num2str(c_err0)])
disp(' ')
tic
while c_err > c_err0
    
    nAttempts = nAttempts + 1;
    
    if nAttempts > threshIterator*1000
        c_err0 = c_err0*2;
        threshIterator = threshIterator + 1;      
        disp(['New threshold: ',num2str(c_err0)])
        disp(['No. of attempts: ',num2str(nAttempts)]);
    end
    
    for iProfile = 1:nProfiles
        f = @(Coef)Resid( Coef, I(:,iProfile), B(iProfile), C_mean0 );
        [Coef(1, iProfile),fval] = ...
            fmincon(f,Coef0(1,iProfile),[],[], [], [], lb, ub, [], options);
    end

    C_mean = mean(((I - onemat*B)./(onemat*Coef)),2);
    c_err = sum(abs((C_mean - C_mean0)));
    C_mean0 = C_mean;
    
    if c_err0 >= 1
        break
    end
end 

disp(['Minimized error: ', num2str(c_err)])
disp(' ')

% %Calculate C(x) for each of n embryos
Amat = ones([size(I,1) 1])*Coef(1,:);
% %Amat,Bmat expand the Coef vectors across the x dimension to matrices for
% %calculation with I
Bmat = ones([size(I,1) 1])*mean(I);
C=((I-Bmat)./Amat);
C_out = C;

end

%%
function Chi = Resid(A,I,B, C_mean)

% %Expand Coef(1) across x for calculation
% Amat = ones([size(I(:,1)) 1])*Coef(1,:);
% Bmat = ones([size(I(:,1)) 1])*Coef(2,:);
% %Calculate average Concentration across n embryos
% Cbar=(1/n)*(sum((I-Amat)./Bmat,2));
% %Calculate residual of Intensities when calculated by average C
% R=(Cbar*Coef(1,:) + ones([size(I(:,1)) 1])*Coef(2,:))-I;
% %Calculate Chi, a sum of squared errors term
% Chi = sum(sum(R.^2));
% end

% B = zeros(size(I,1),1);
% A = ones(size(I,1),1)*Coef();

Chi = sum((I - A .* C_mean - B).^2);

end