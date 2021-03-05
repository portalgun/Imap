classdef imapBin_plot < handle & imapCommon_plot
methods
    function obj=plot_prog(obj)
        if obj.plotOpts.bProg || obj.plotOpts.bSaveProg
            obj.plot_bins_img(1);
        end
        if obj.plotOpts.bSaveProg
            obj.save_fig('prog','hist');
        end
    end
%%
    function obj=plot_bins_img(obj,bProg)
        if ~exist('bProg','var') || isempty(bProg)
            bProg=0;
        end
        obj.fig_fun('prog');
        hold off

        subPlot([1,2],1,1);
        imapBin.plot_bins_img_f(obj.I,obj.k,obj.edges,obj.counts,obj.bLogBin);

        subPlot([1,2],1,2);
        imapBin.plot_imap(obj.bin,[],obj.nBin);

        obj.pos_fun('prog',[],[1200,800]);
        drawnow

        if ~bProg
            obj.save_fig('prog','hist');
        end
    end
    function obj=plot_bins(obj)
        obj.fig_fun('bins');
        hold off

        counts=obj.counts;
        if size(counts,1) > 1 && size(counts,2) > 2
            counts=sum(counts,[3,2]);
        end

        imapBin.plot_bins_f(obj.edges,counts,obj.bLogBin);

        obj.pos_fun('prog',[],[1200,800]);
        %drawnow

        obj.save_fig('bins','hist',0,0);
    end
    function obj=plot_bins_LR(obj)
        obj.fig_fun('binsLR');
        hold off

        imapBin.plot_bins_LR_f(obj.edges,obj.counts,obj.bLogBin);

        obj.sg_fun('binsLR','imapBin');
        obj.pos_fun('binsLR',[],[1800,900]);
        drawnow

        obj.save_fig('binsLR','hist',0,3);
    end
%%
    function obj=plot_count_dist_p(obj)
        obj.fig_fun('dist')
        imapBin.plot_count_dist(obj.counts);
        obj.save_fig('dist','hist',0,4);
        drawnow
    end
end
methods(Static=true)
%% PLOT
    function plot_bins_LR_f(edges,counts,bLog)

        subPlot([1,2],1,1);
        imapBin.plot_bins_LorR_f(1,edges,counts,bLog);

        subPlot([1,2],1,2);
        imapBin.plot_bins_LorR_f(2,edges,counts,bLog);

    end
    function plot_bins_f(edges,counts,bLog)
        c=sum(counts,[2,3]);
        h=histo([],edges,'counts',counts,'bLog',bLog,'bPlot',1);


        imapBin.format_fun(h);
        imapBin.title_fun(0,h,[]);
    end
    function plot_bins_LorR_f(k,edges,counts,bLog)
        c=sum(counts,2);
        c=c(:,k);
        h=histo([],edges,'counts',c,'bLog',bLog,'bPlot',1);

        imapBin.format_fun(h);
        imapBin.title_fun(k,h,[]);
    end
    function plot_bins_img_f(I,k,edges,counts,bLog)
        c=counts(:,I,k);
        h=histo([],edges,'counts',c,'bLog',bLog,'bPlot',1);
        imapBin.format_fun(h);
        imapBin.title_fun(k,h,I);
    end
%%
    function format_fun(h)
        bins=round(linspace(1,h.nBins,8));
        ctrs=h.cntrs(bins);
        ticksl=arrayfun(@(x,y) [num2str(x,'%02i') ': ' num2str(y)] ,bins,ctrs,UO,false);

        xticks(ctrs);
        xticklabels(ticksl);
        xlim([0  h.nBins]);
        xtickangle(270);
        axis square;
    end
    function title_fun(k,h,I)
        if k==1
            LR='L';
        elseif k==2
            LR='R';
        elseif k==0;
            LR='B';
        end
        if exist('I','var') && ~isempty(I)
            str=num2str(I,'%04i');
        else
            str='A';
        end

        md=num2str(find(h.counts==max(h.counts)));
        titl=['imapBin' newline LR str newline 'mode=' md];

        formatFigure('X','counts',titl);
    end
%%%
    function []=plot_imap(imap,edges,nBin)
        h=imagesc(imap);

        formatImage();
        colormap(hot);
        %rang=min(imap(:)):max(imap(:));
        rang=[1 nBin];
        bins=round(linspace(1,nBin,8));
        ticksl=arrayfun(@(x) num2str(x) ,bins,UO,false);

        cb=colorbar('Ticks',bins);
        caxis([1 nBin]);
        cbarlabel(cb,'bins');

        set(gca,'color','blue') ;
        set(h,'alphadata',~isnan(imap)); % make nans transparent
    end
%%
    function plot_count_dist(counts)
        imSorted=sort( sum(counts(:,:,1),3), 2);

        [~,binImIdxSum]=sort(sum(imSorted,2),1);
        binImSortedSum=imSorted(binImIdxSum,:);

        [~,binImIdxMax]=sort(max(imSorted,[],2),1);
        binImSortedMax=imSorted(binImIdxMax,:);


        [~,binImIdxVar]=sort(var(imSorted,1,2),1);
        binImSortedVar=imSorted(binImIdxVar,:);

        colormap(hot);


        N=3;

        subPlot([1,N], 1,1);
        imagesc(imSorted)
        xlabel('Image'); ylabel('Bin');
        xticks([]);
        axis square;
        colorbar;


        subPlot([1,N], 1,2);
        imagesc(binImSortedSum)
        yticks(1:size(counts,1))
        yticklabels(num2str(binImIdxSum))
        xticks([]);
        title('Total');
        axis square
        ax=gca;
        ax.FontSize=7;


        subPlot([1,N], 1,3);
        imagesc(binImSortedMax)
        yticks(1:size(counts,1));
        yticklabels(num2str(binImIdxMax));
        xticks([]);
        title('Max');
        axis square
        ax=gca;
        ax.FontSize=7;


        %subPlot([1,N], 1,3)
        %imagesc(binImSortedMax)
        %yticks(1:size(counts,1))
        %xticks([]);
        %yticklabels(num2str(binImIdxMax))
        %title('Max');
        %axis square

        subPlot([1,N], 1,3);
        imagesc(binImSortedVar)
        yticks(1:size(counts,1));
        xticks([]);
        yticklabels(num2str(binImIdxVar));
        title('Var');
        axis square
        ax=gca;
        ax.FontSize=7;

        drawnow
        pos=get(gcf,'Position');
        pos(3:4)=[1640,400];
        set(gcf,'Position',pos);

    end
end
end
