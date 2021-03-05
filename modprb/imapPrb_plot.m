classdef imapPrb_plot < handle
methods
    function plot2(obj,ind1,ind2)
        if ~exist('ind1','var') || isempty(ind1)
            ind1=1;
            ind2=2;
        end
        P=marginalize_fun(obj.P,ind1,ind2);
        imapPrb.plot_fun(P,obj.edges{ind1},obj.edges{ind2});
        title('Probability distribution')
        set(gcf,'Position',[0 0 900 900]);
        xlabel(obj.aliases{1});
        ylabel(obj.aliases{2});

        function P=marginalize_fun(P,ind1,ind2)
            %ind1=3;
            %ind2=4;
            %P=rand(1,2,3,4,5,6)

            n=ndimsSane(P);
            if ndimsSane(P) == 2 && (ind1 == 1 && ind2 ==2)
                return
            elseif ndimsSane(P) == 2 && (ind1 == 2 && ind2 ==1)
                P=transpose(P);
                return
            end
            dims=n:-1:1;
            dims(ismember(dims,[ind1,ind2]))=[];
            P=squeeze(sum(P,dims));

        end
    end
end
methods(Static=true)
    function plot_fun(slice2D,edges1,edges2,bPrb)

        %  CHECK
        %slice2D(1,1)=.01;
        %slice2D(end,end)=.01;
        slice2D=transpose(slice2D)

        bbins1=(1:length(edges1));
        bbins2=(1:length(edges2));

        h=imagesc(1.5,1.5,slice2D);
        colorbar;
        colormap hot;
        set(gca,'YDir','normal')


        ticksl1=arrayfun(@(x,y) [num2str(x,'%02i') ': ' num2str(y)] ,bbins1,edges1,UO,false);
        ticksl2=arrayfun(@(x,y) [num2str(x,'%02i') ': ' num2str(y)] ,bbins2,edges2,UO,false);

        xticks([0 1 11 52]);
        xticks(bbins1);
        yticks(bbins2);
        xticklabels(ticksl1);
        yticklabels(ticksl2);
        xtickangle(270);
        ytickangle(0);

        set(gca,'color',[.2 .2 .2]) ;
        set(h,'alphadata',slice2D~=0); % make nans transparent
        set(gcf, 'InvertHardcopy', 'off')
        axis square
    end
end
end
