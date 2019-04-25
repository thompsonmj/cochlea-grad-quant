function makegifofplot(x,varargin)
%
% B5RawDat.Sox2

fig = figure;

nData = numel(varargin);

nZ = size(varargin{1},2);

im_U = cell(nZ,1);

for iZ = 1:nZ
    h = struct;
    for iData = 1:nData
        hold on
        data = varargin{iData};
        h(iData) = plot(x,data(:,iZ));
        grid on
        fig.Color = 'w';
        xlim([0, max(x)])
        ylim([0, max(max(data))])
        title([varname(data),' ','Z',num2str(iZ)]);
        xlabel('x/L');
        ylabel('Intensity [AU]');
    end
    
    M_U = getframe(fig);
    im_U{iZ} = frame2im(M_U); 
    for iData = 1:nData
        delete(h(iData))
    end
end

M_name = sprintf('test.gif');

for idx=1:length(im_U)
    [A,map] = rgb2ind(im_U{idx},256);
        if idx == 1
            imwrite(A,map,M_name,'gif','LoopCount',Inf,'DelayTime',0.5);
        else
            imwrite(A,map,M_name,'gif','WriteMode','append','DelayTime',0.5);
        end
end

    function out = varname(var)
        out = inputname(1);
    end

end