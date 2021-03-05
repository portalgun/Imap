classdef imapGen_plot < handle
methods
    function obj=plot_prog(obj)
        if obj.plotOpts.bProg || obj.plotOpts.bSaveProg
            obj.plot();
        end
        if  obj.plotOpts.bSaveProg
            obj.save_prog();
        end
    end
    function obj=plot(obj)
        % FIGNUM
        obj.fig_fun('prog');
        name=get_name_fun(obj);
        units=get_units(obj);
        pht=obj.plotOpts.pht{obj.k};
        imapGen.plot_f(obj.gen, name,units,pht);

        % TILE
        titl=['imgNum ' num2str(obj.I) ' ' obj.LorR];

        obj.sg_fun('prog',titl);

        % POS
        obj.pos_fun('prog',[],[1800,500]);
        drawnow
        function name=get_name_fun(obj)
            k=sed('s', obj.genOpts.type.name, '^X_','');
            name=strrep(k,'_',' ');
        end
        function units=get_units(obj)
            k=sed('s', obj.genOpts.type.name, '^X_','');
            params=imapGen_modules.(['params_' k]);
            if isfield(params,'units')
                units=params.units;
            else
                units=[];
            end
        end
    end
end
methods(Static=true)
    function []=plot_f(imap,imapName,imapUnits,pht)
        if exist('pht','var') && ~isempty(pht)
            ax=subPlot([1,2],1,1);
            imagesc(pht)
            formatImage();
            formatFigure('','','Pht')
            colormap(ax,gray);

            n=2;
        else
            n=1;
        end
        ax=subPlot([1,n],1,n);
        h=imagesc(imap);
        set(gca,'color','blue') ;
        set(h,'alphadata',~isnan(imap)); % make nans transparent
        formatImage();
        colormap(ax,hot);
        cb=colorbar;
        if exist('imapName') && ~isempty(imapName)
            formatFigure('','',imapName);
        end
        if exist('imapUnits') && ~isempty(imapUnits)
            cbarlabel(cb,imapUnits);
        end
    end
end
end
