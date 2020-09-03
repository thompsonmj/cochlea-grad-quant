function map = constructdecodingmap(Y,x)
%CONSTRUCTDECODINGMAP <description>

% Inputs
%   > Y: nX x nSamples x nChannels
%   > x: nX x 1 array

%% Full dataset stats
g_mean = mean(Y,2);

Y = (Y - min(g_mean))/(max(g_mean) - min(g_mean));
g_mean = mean(Y,2);
g_std = std(Y,0,2);










%% For reference
% save('jag1_chi2_not-smooth.mat')
load('psmad_chi2_not-smooth.mat')
% 
% Y = Y(1:651,:);
% 
[nSamps,nCoch] = size(Y);
for iC = 1:nCoch
    Y(:,iC) = smoothrawdata(Y(:,iC),'loess',400);
end
%% Full dataset stats
g_mean = mean(Y,2);

Y = (Y - min(g_mean))/(max(g_mean) - min(g_mean));
g_mean = mean(Y,2);
g_std = std(Y,0,2);

%%
% figure,plot(Y)
iC = 2;
Z = 1;
% for iC = 1:nCoch
    for idx_x_imp = 1:nSamps
        for idx_x = 1:nSamps
            g_alpha_at_x = Y(idx_x,iC);
            g_mean_at_x_imp = g_mean(idx_x_imp);
            g_std_at_x_imp = g_std(idx_x_imp);

            chi2_for_g_alpha_at_x = ...
                (g_alpha_at_x - g_mean_at_x_imp)^2/(g_std_at_x_imp^2);

            P_of_g_alpha_at_x_given_x_imp = (1/Z)* ...
                (sqrt(2*pi*g_std_at_x_imp^2))*exp(-chi2_for_g_alpha_at_x/2)*(1/801);

            P(idx_x_imp,idx_x,iC) = P_of_g_alpha_at_x_given_x_imp;
        end
    end
% end
P = mean(P,3);
figure
P = rot90(P);
imagesc(P)
truesize
load('colormaps.mat')
colormap(cmap_psmad)
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
xlabel('Actual position (x/L)')
ylabel('Implied position (x*/L)')


figure
x = (0.1:0.001:0.9);
plot(x,Y,'Color',[0.5,0.5,0.5])
hold on
% Use the colors for jag1, psmad, and sox2 to represent the 3 embryos
% chosen as examples.
plot(x,Y(:,1),'Color',jag1_color,'linew',3)
plot(x,Y(:,2),'Color',psmad_color,'linew',3)
plot(x,Y(:,11),'Color',sox2_color,'linew',3)
plot(x,g_mean,'Color','k','lines',':','linew',3)
xlabel('Position (x/L)')
ylabel('P-Smad')
xticks([0.1,0.9])
yticks([0,1])