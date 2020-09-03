function axOut = addscalebar(axIn,scale,length)
%ADDSCALEBAR

% Inputs
%   > axIn: axis to add scale bar to
%   > scale: in pixels/micron
%   > length: length of scalebar to create

x = zeros(1,1);

[yL,xL] = size(axIn.CData);

%% Bottom right anchor
x2 = round(xL*0.95);
y2 = round(yL*0.95);

%%
x1 = x2 - round(scale*length);
y1 = round(yL*0.95);    


%%
hold on
axOut = plot([x1;x2], [y1,y2], ...
    'Color', 'white', ...
    'LineWidth', 2);
str = [num2str(length),' µm'];
text(x2-round(0.12*xL),y2-(0.08*yL),str, ...
    'Color','white')

end
