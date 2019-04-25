figure
hold on
x = [0.001:0.001:1];

%% Sox2
meanNormBS = mean(normBS,2);
stdNormBS = std(normBS,0,2);

plusSTD = meanNormBS + stdNormBS;
minusSTD = meanNormBS - stdNormBS;

plot( x,normBS, 'Color', 'b', 'LineStyle', ':' )
plot( x,plusSTD, 'Color', 'b', 'LineStyle', '--' )
plot( x,minusSTD, 'Color', 'b', 'LineStyle', '--' )
plot( x,meanNormBS, 'Color', 'b', 'LineWidth', 2)

[y1h, y2h, h] = fill_between(x, plusSTD, minusSTD, 1, ...
    'EdgeColor', 'none', ...
    'FaceColor', 'b');
alpha(0.1)
xlim([0, 1])
ylim([0, 1])
xlabel('Relative circumferential positoin')
ylabel('\chi^2 norm fluorescence')
title('Population Sox2 data')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pSmad
meanNormBP = mean(normBP,2);
stdNormBP = std(normBP,0,2);

plusSTD = meanNormBP + stdNormBP;
minusSTD = meanNormBP - stdNormBP;

plot( x,normBP, 'Color', 'r', 'LineStyle', ':' )
plot( x,plusSTD, 'Color', 'r', 'LineStyle', '--' )
plot( x,minusSTD, 'Color', 'r', 'LineStyle', '--' )
plot( x,meanNormBP, 'Color', 'r', 'LineWidth', 2)

[y1h, y2h, h] = fill_between(x, plusSTD, minusSTD, 1, ...
    'EdgeColor', 'none', ...
    'FaceColor', 'r');
alpha(0.1)
xlim([0, 1])
ylim([0, 1])
xlabel('Relative circumferential positoin')
ylabel('\chi^2 norm fluorescence')
title('Population Data')
