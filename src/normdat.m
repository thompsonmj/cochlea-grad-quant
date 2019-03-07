function normOutput = normdat(profileSet)

%%%	use sparse matrix for inversion in the chi^2 norm code. not sure if sparse already used

%%%load('Data8DMU_test.mat');
%%%load('Data8DMU_Noi_test.mat'); % Replaced with below
load('psmadDat.mat');

%%%nEmbryos = 5000; %embryoSize;  % Here you could just change the number of embryos you would 
                  %like to use in the normalization.


[nPts,nProfiles] = size(profileSet);
                  
% Rescales data to [0,1] interval
%%%xScaled = (0:0.02:1)'; % Replaced with below
xScaled = (0:1/(nPts-1):1)';
%%%dpp_matrix = zeros(51,nEmbryos);
dpp_noise_matrix = zeros(nPts,nProfiles);
dpp_extr_matrix = zeros(nPts,nProfiles);
dpp_extr_matrix2 = zeros(nPts,nProfiles);
dpp_int_matrix = zeros(nPts,nProfiles);

index = 1;

% Specific call to normalization algorithms
    for i = 1:nProfiles
        %%%Data_ini(:,i) = data_out{1,i}(3,:)';
        %%%Data(:,i) = dataF{1,i}(3,:)'; % Replaced with below
        Data(:,i) = profileSet(:,i);
%         Data(:,i) = signalSet{1,i}(1,:)';
    end

% Normalization    
 for j = 1:nProfiles   
    %%%dpp_matrix(:,j) = Data_ini(:,j);
    dpp_noise_matrix(:,j) = Data(:,j);
    dpp_extr_matrix(:,j) = extrema_norm(Data(:,j));
    dpp_extr_matrix2(:,j) = extrema_norm2(Data(:,j));
    dpp_int_matrix(:,j) = integral_norm(Data(:,j));
end
        
% Minimizing Error Normalization
chi2_norm_dpp = chi_sq_norm(Data);
size(chi2_norm_dpp)

% Statistical operations on output
%%%mean_dpp_raw = mean(dpp_matrix')';
%%%    min_temp = min(mean_dpp_raw);
%%%    max_temp = max(mean_dpp_raw);
%%%mean_dpp_raw = (mean_dpp_raw-min_temp)/(max_temp-min_temp);
%%%dpp_matrix = (dpp_matrix-min_temp)/(max_temp-min_temp);
%%%std_dpp_raw = std(dpp_matrix')';

mean_dpp_noise_raw = mean(dpp_noise_matrix')';
    min_temp = min(mean_dpp_noise_raw);
    max_temp = max(mean_dpp_noise_raw);
mean_dpp_noise_raw = (mean_dpp_noise_raw-min_temp)/(max_temp-min_temp);
dpp_noise_matrix = (dpp_noise_matrix-min_temp)/(max_temp-min_temp);
std_dpp_noise_raw = std(dpp_noise_matrix')';

mean_dpp_ext = mean(dpp_extr_matrix')';
    min_temp = min(mean_dpp_ext);
    max_temp = max(mean_dpp_ext);
mean_dpp_ext = (mean_dpp_ext-min_temp)/(max_temp-min_temp);
dpp_extr_matrix = (dpp_extr_matrix-min_temp)/(max_temp-min_temp);
std_dpp_ext = std(dpp_extr_matrix')';

mean_dpp_ext2 = mean(dpp_extr_matrix2')';
    min_temp = min(mean_dpp_ext2);
    max_temp = max(mean_dpp_ext2);
mean_dpp_ext2 = (mean_dpp_ext2-min_temp)/(max_temp-min_temp);
dpp_extr_matrix2 = (dpp_extr_matrix2-min_temp)/(max_temp-min_temp);
std_dpp_ext2 = std(dpp_extr_matrix2')';

mean_dpp_int = mean(dpp_int_matrix')';
    min_temp = min(mean_dpp_int);
    max_temp = max(mean_dpp_int);
mean_dpp_int = (mean_dpp_int-min_temp)/(max_temp-min_temp);
dpp_int_matrix = (dpp_int_matrix-min_temp)/(max_temp-min_temp);
std_dpp_int = std(dpp_int_matrix')';

mean_dpp_chi = mean(chi2_norm_dpp')';
    min_temp = min(mean_dpp_chi);
    max_temp = max(mean_dpp_chi);
mean_dpp_chi = (mean_dpp_chi-min_temp)/(max_temp-min_temp);
chi2_norm_dpp = (chi2_norm_dpp-min_temp)/(max_temp-min_temp);
std_dpp_chi = std(chi2_norm_dpp')';

%%%NormOutput_DMU.initial = dpp_matrix;

figure(20)
plot(dpp_noise_matrix)
title('Input Data');
xlabel('Circumferencial Position');
ylabel('Concentration(relative)');
NormOutput_DMU.raw = dpp_noise_matrix;
saveas(gcf, 'Original input data.jpg')

figure
plot(chi2_norm_dpp)
title('Output Data by Minimizing Error');
xlabel('Circumferencial Position');
ylabel('Concentration(relative)');
saveas(gcf, 'Original output by minimizing error.jpg')
NormOutput_DMU.chi = chi2_norm_dpp;
    
figure
plot(dpp_extr_matrix)
title('Output Data by Pinning Extremes');
xlabel('Circumferencial Position');
ylabel('Concentration(relative)');
saveas(gcf, 'Original output by pinning extremes.jpg')
NormOutput_DMU.ext = dpp_extr_matrix;

figure
plot(dpp_extr_matrix2)
title('Output Data by Pinning Extremes');
xlabel('Circumferencial Position');
ylabel('Concentration(relative)');
saveas(gcf, 'Original output by pinning extremes.jpg')
NormOutput_DMU.ext2 = dpp_extr_matrix2;

figure
plot(dpp_int_matrix)
title('Output Data by Integral Nomalization');
xlabel('Circumferencial Position');
ylabel('Concentration(relative)');
saveas(gcf, 'Original output by integral.jpg')
NormOutput_DMU.int = dpp_int_matrix;
normOutput = NormOutput_DMU;
save NormOutput8DMU_test.mat normOutput
end

%% Function for calculation of pinning extremes normalization

function [norm_out] = extrema_norm(I_vector)

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
norm_out = xy_ascending_x;

end


%% Function for AP max and min reset
function [norm_out] = extrema_norm2(I_vector)

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
norm_out = xy_ascending_x;

end

%% Function for calculation of integral normalization
function norm_data = integral_norm(data_in)

    C2_L=data_in;
    integC2_L=trapz(C2_L);    
    norm_data=C2_L/(integC2_L);
    
end

%% Functions for minimiziation of squarred-error
function C_out = chi_sq_norm(I)

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
c_err = 51;

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
    
    if mod(nAttempts,500) == 0
        disp(['No. of attempts: ',num2str(nAttempts)]);
        toc
        disp(' ')
    end
    
    if nAttempts > threshIterator*1000
        c_err0 = c_err0*2;
        threshIterator = threshIterator + 1;
        disp('Relaxing error threshold.')
        disp(['New threshold: ',num2str(c_err0)])
        disp(' ')
    end
    
    for iProfile = 1:nProfiles
        f = @(Coef)Resid( Coef, I(:,iProfile), B(iProfile), C_mean0 );
        [Coef(1, iProfile),fval] = fmincon(f,Coef0(1,iProfile),[],[], [], [], lb, ub, [], options);
    end

    C_mean = mean(((I - onemat*B)./(onemat*Coef)),2);
    c_err = sum(abs((C_mean - C_mean0)));
    C_mean0 = C_mean;
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