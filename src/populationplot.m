figure
hold on
x = [1/350:1/350:1];

% %% Sox2
% meanNormBS = mean(normBS,2);
% stdNormBS = std(normBS,0,2);
% 
% plusSTD = meanNormBS + stdNormBS;
% minusSTD = meanNormBS - stdNormBS;
% 
% plot( x,normBS, 'Color', 'b', 'LineStyle', ':' )
% plot( x,plusSTD, 'Color', 'b', 'LineStyle', '--' )
% plot( x,minusSTD, 'Color', 'b', 'LineStyle', '--' )
% plot( x,meanNormBS, 'Color', 'b', 'LineWidth', 2)
% 
% [y1h, y2h, h] = fill_between(x, plusSTD, minusSTD, 1, ...
%     'EdgeColor', 'none', ...
%     'FaceColor', 'b');
% alpha(0.1)
% xlim([0, 1])
% ylim([0, 1])
% xlabel('Relative circumferential positoin')
% ylabel('\chi^2 norm fluorescence')
% title('Population Sox2 data')
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% pSmad
% meanNormBP = mean(normBP,2);
% stdNormBP = std(normBP,0,2);
% 
% plusSTD = meanNormBP + stdNormBP;
% minusSTD = meanNormBP - stdNormBP;


meanPsmadOC;
highStd;
lowStd;
%% 1. align, 2. crop, 3. norm
% yyaxis left
% % % plot(x,psmadOCNew,'Color','r','LineStyle',':')
% % % plot(x,highStd,'Color','r','LineStyle','--')
% % % plot(x,lowStd,'Color','r','LineStyle','--')
% % % plot(x,meanPsmadOC,'Color','r','LineWidth',2)
% % % xlabel('Position along presumptive OC, L')
% % % ylabel('\chi^2 norm fluorescence')
% % % 
% % % [y1h,y2h,h] = fill_between(x, highStd, lowStd, 1, ...
% % %     'EdgeColor','none', ...
% % %     'FaceColor','r');

%% 1. align, 2. norm, 3. crop
plot(x,psmadNew2,'Color','r','LineStyle',':')
plot(x,highStd2,'Color','r','LineStyle','--')
plot(x,lowStd2,'Color','r','LineStyle','--')
plot(x,meanPsmadOC2,'Color','r','LineWidth',2)
xlabel('Position along presumptive OC, L')
ylabel('\chi^2 norm fluorescence')

[y1h,y2h,h] = fill_between(x, highStd2, lowStd2, 1, ...
    'EdgeColor','none', ...
    'FaceColor','r');
alpha(0.1)
% hold off
yyaxis right
plot(x(1:end-1),PE2(:,1)/350)
ylabel('Positional Error (\sigma_x/L)','Color','k')

% plot( x,normBP, 'Color', 'r', 'LineStyle', ':' )
% plot( x,plusSTD, 'Color', 'r', 'LineStyle', '--' )
% plot( x,minusSTD, 'Color', 'r', 'LineStyle', '--' )
% plot( x,meanNormBP, 'Color', 'r', 'LineWidth', 2)
% 
% [y1h, y2h, h] = fill_between(x, plusSTD, minusSTD, 1, ...
%     'EdgeColor', 'none', ...
%     'FaceColor', 'r');
% alpha(0.1)
% xlim([0, 1])
% ylim([0, 1])

title('pSmad')
