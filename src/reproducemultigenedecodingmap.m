% % function pd = conditionalpdgauss(g.data.Hb,x,std_x)
% 
% %% Load and setup
clear
gdir = 'F:\projects\cochlea\data\published-datasets\optimal-decoding-of-cellular-identities-in-a-genetic-network\drosophila\Data\Gap\';
gdata = 'gap_data_raw_dorsal_wt.mat';
load(fullfile(gdir,gdata));

nEmbs = numel(data);
nSamps = numel(data(1).Hb);
x = (1/nSamps:1/nSamps:1);
idx_low = round(nSamps)*0.1;
idx_high = round(nSamps)*0.9;
% Y = zeros(nSamps,nEmbs);
% Y = Y(idx_low:idx_high);

genes = {'Hb','Kr','Gt','Kni'};
K = numel(genes);
G = cell(K,1);
for ii = 1:K
    Y = zeros(nSamps,nEmbs);
  
    for iE = 1:nEmbs
        Y(:,iE) = data(iE).(genes{ii});
    %     Y(:,iE) = data(iE).Kr;
    %     Y(:,iE) = data(iE).Gt;
    %     Y(:,iE) = data(iE).Kni;
    end
    Y = Y(idx_low:idx_high,:);

    G{ii} = Y;
end

x = x(idx_low:idx_high);
nSamps = numel(Y(:,1));
%%% SECTION WORKING FOR 4 GENES
%% Normalize data using Chi^2
% for ii = 1:K
%     normOut = normdat(G{ii});
%     G{ii} = normOut.chiSq;
% end
% normOut = normdat(Y);
% Y = normOut.chiSq;
%% Full dataset stats
G_mean = mean(Y,2);

Y = (Y - min(g_mean))/(max(g_mean) - min(g_mean));
g_mean = mean(Y,2);

g_std = std(Y,0,2);
%% Test Gaussian approximation for distribution of expression levels at each point
% % Recreate Fig. 1C in "Positional information, in bits"
% 
% % Gaussian with zero mean and unit variance for reference.
% delta = -4:0.1:4;
% pd = makedist('Normal','mu',0,'sigma',1');
% pdf_n = pdf(pd,delta);
% 
% % Fit data to normal
% delta_data = zeros(nSamps,nEmbs);
% for iE = 1:nEmbs
%     g = Y(:,iE);
%     for ix = 1:nSamps
%         delta_data(ix,iE) = (g(ix) - g_mean(ix))/g_std(ix);
%     end
% end
% % 
% % % dd = delta_data(:,1);
% % % for iE = 2:nEmbs
% % %     dd = vertcat(dd,delta_data(:,iE));
% % % end
% % % h = histfit(dd,20,'normal');
% % 
% edges = -4.4:0.4:4.4;
% binCenters = -4.2:0.4:4.2;
% h = zeros(nSamps,numel(binCenters));
% for ix = 1:nSamps
%     h(ix,:) = histcounts(delta_data(ix,:),edges,'Normalization','pdf');
% end
% 
% figure,scatter(binCenters,mean(h,1))
% err = std(h,0,1);
% errorbar(binCenters,mean(h,1),err,'o')
% h = histogram(delta_data,edges,'Normalization','pdf');
% 
% % Gaussian
% hold on
% plot(delta,pdf_n, ...
%     'Color',[0.7,0.7,0.7], ...
%     'LineWidth',2)
% xlabel('[g-g_bar(x)]/sigma_g(x)','Interpreter','none')
% ylabel('pdf')
% ylim([0,0.5])
% legend('Hb data','Gaussian')


%% Calculate Chi^2
chi2 = zeros(nSamps,1);
intensities = (0:0.01:1);
nIntensities = numel(intensities);
P = zeros(nIntensities,nSamps);
iE = 5;
g = Y(:,iE);
for iI = 1:nIntensities
    for ix = 1:nSamps
        chi2(ix) = (intensities(iI) - g_mean(ix))/(g_std(ix)^2);
        P(iI,ix) = (1/sqrt(2*pi*g_std(ix)^2))*exp(-chi2(ix)^2/2);
    end
end

% Cylce over all possible implied positions x_star (0.1:0.9) and calculate
% the probability for each one given the actual gene expression value for
% an embryo at the matching actual position x.

%% Attempt 2
% iE = 3;
P = zeros(nSamps,nSamps,nEmbs);
Z = 1e0;
for iE = 1:nEmbs
    for idx_x_imp = 1:nSamps
        for idx_x = 1:nSamps
            g_alpha_at_x = Y(idx_x,iE);
            g_mean_at_x_imp = g_mean(idx_x_imp);
            g_std_at_x_imp = g_std(idx_x_imp);

            chi2_for_g_alpha_at_x = ...
                (g_alpha_at_x - g_mean_at_x_imp)^2/(g_std_at_x_imp^2);

            P_of_g_alpha_at_x_given_x_imp = (1/Z)* ...
                (sqrt(2*pi*g_std_at_x_imp^2))*exp(-chi2_for_g_alpha_at_x/2)*(1/801);

            P(idx_x_imp,idx_x,iE) = P_of_g_alpha_at_x_given_x_imp;
        end
    end
end
P = mean(P,3);
figure
P = rot90(P);
imagesc(P)
truesize
load('colormaps.mat')
colormap(cmap_topro3)
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
xlabel('Actual position (x/L)')
ylabel('Implied position (x*/L)')

figure
plot(x,Y,'Color',[0.5,0.5,0.5])
hold on
% Use the colors for jag1, psmad, and sox2 to represent the 3 embryos
% chosen as examples.
plot(x,Y(:,52),'Color',jag1_color,'linew',3)
plot(x,Y(:,93),'Color',psmad_color,'linew',3)
plot(x,Y(:,3),'Color',sox2_color,'linew',3)
plot(x,g_mean,'Color','k','lines',':','linew',3)
xlabel('Position (x/L)')
ylabel('Kni')
xticks([0.1,0.9])
yticks([0,1])

% jag1_color % embryo 52 (max)
% psmad_color % embryo 93 (min)
% sox2_color % embryo 3 (mid)

%% Now using my data
% load(fullfile('..','..','..','data','cochlea-data_2020-02-24_14-57-27.mat'),'data')
% load('colormaps.mat')
% nSections = numel(data);
% Y = zeros(1000,1);
% ii = 0;
% for iS = 1:nSections
%     if data(iS).flag && ...
%             ~isempty(data(iS).jag1) && ...
%             data(iS).age == 12.5
%         ii = ii+1;
%         y = uniformsample(data(iS).jag1,1000);
%         Y(:,ii) = y;
%     end
% end
% 
% normOut = normdat(Y);
% Y = normOut.chiSq;
% Y_mean = mean(Y,2);
% Y = (Y - min(Y_mean))/(max(Y_mean) - min(Y_mean));
% Y = Y(100:900,:);
% save('jag1_chi2_not-smooth.mat')
% load('psmad_chi2_not-smooth.mat')
% 
% Y = Y(1:651,:);
% 
% [nSamps,nCoch] = size(Y);
% for iC = 1:nCoch
%     Y(:,iC) = smoothrawdata(Y(:,iC),'loess',400);
% end
% %% Full dataset stats
% g_mean = mean(Y,2);
% 
% Y = (Y - min(g_mean))/(max(g_mean) - min(g_mean));
% g_mean = mean(Y,2);
% g_std = std(Y,0,2);
% 
% %%
% % figure,plot(Y)
% iC = 2;
% Z = 1;
% % for iC = 1:nCoch
%     for idx_x_imp = 1:nSamps
%         for idx_x = 1:nSamps
%             g_alpha_at_x = Y(idx_x,iC);
%             g_mean_at_x_imp = g_mean(idx_x_imp);
%             g_std_at_x_imp = g_std(idx_x_imp);
% 
%             chi2_for_g_alpha_at_x = ...
%                 (g_alpha_at_x - g_mean_at_x_imp)^2/(g_std_at_x_imp^2);
% 
%             P_of_g_alpha_at_x_given_x_imp = (1/Z)* ...
%                 (sqrt(2*pi*g_std_at_x_imp^2))*exp(-chi2_for_g_alpha_at_x/2)*(1/801);
% 
%             P(idx_x_imp,idx_x,iC) = P_of_g_alpha_at_x_given_x_imp;
%         end
%     end
% % end
% P = mean(P,3);
% figure
% P = rot90(P);
% imagesc(P)
% truesize
% load('colormaps.mat')
% colormap(cmap_psmad)
% set(gca,'YTickLabel',[]);
% set(gca,'XTickLabel',[]);
% xlabel('Actual position (x/L)')
% ylabel('Implied position (x*/L)')
% 
% 
% figure
% x = (0.1:0.001:0.9);
% plot(x,Y,'Color',[0.5,0.5,0.5])
% hold on
% % Use the colors for jag1, psmad, and sox2 to represent the 3 embryos
% % chosen as examples.
% plot(x,Y(:,1),'Color',jag1_color,'linew',3)
% plot(x,Y(:,2),'Color',psmad_color,'linew',3)
% plot(x,Y(:,11),'Color',sox2_color,'linew',3)
% plot(x,g_mean,'Color','k','lines',':','linew',3)
% xlabel('Position (x/L)')
% ylabel('P-Smad')
% xticks([0.1,0.9])
% yticks([0,1])

%% Gaussian approx validation
% load('psmad_chi2_not-smooth.mat')
% 
% Y = Y(1:651,:);
% 
% [nSamps,nCoch] = size(Y);
% for iC = 1:nCoch
%     Y(:,iC) = smoothrawdata(Y(:,iC),'loess',300);
% end
% %% Full dataset stats
% g_mean = mean(Y,2);
% 
% Y = (Y - min(g_mean))/(max(g_mean) - min(g_mean));
% g_mean = mean(Y,2);
% g_std = std(Y,0,2);
% 
% delta_data = zeros(nSamps,nCoch);
% for iC = 1:nCoch
%     g = Y(:,iC);
%     for ix = 1:nSamps
%         delta_data(ix,iC) = (g(ix) - g_mean(ix))/g_std(ix);
%     end
% end
% % 
% % % dd = delta_data(:,1);
% % % for iE = 2:nEmbs
% % %     dd = vertcat(dd,delta_data(:,iE));
% % % end
% % % h = histfit(dd,20,'normal');
% % 
% edges = -4.4:0.4:4.4;
% binCenters = -4.2:0.4:4.2;
% h = zeros(nSamps,numel(binCenters));
% for ix = 1:nSamps
%     h(ix,:) = histcounts(delta_data(ix,:),edges,'Normalization','pdf');
% end
% 
% figure
% % scatter(binCenters,mean(h,1))
% err = std(h,0,1);
% errorbar(binCenters,mean(h,1),err,'o')
% hold on
% delta = -4:0.1:4;
% pd = makedist('Normal','mu',0,'sigma',1');
% pdf_n = pdf(pd,delta);
% plot(delta,pdf_n, ...
%     'Color',[0.7,0.7,0.7], ...
%     'LineWidth',2)
% xlabel('[g-g_bar(x)]/sigma_g(x)','Interpreter','none')
% ylabel('pdf')
% ylim([0,0.5])
% legend('P-Smad data','Gaussian')
% % % % % hold on
% % % % % plot(delta,pdf_n, ...
% % % % %     'Color',[0.7,0.7,0.7], ...
% % % % %     'LineWidth',2)
% % % % % xlabel('[g-g_bar(x)]/sigma_g(x)','Interpreter','none')
% % % % % ylabel('pdf')
% % % % % ylim([0,0.5])
% % % % % legend('Hb data','Gaussian')