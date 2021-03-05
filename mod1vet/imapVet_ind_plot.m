classdef imapVet_ind_plot < handle
methods(Access=protected)
    function obj=debug_plot(obj,titl,fnum,anchor)
        if ~exist('titl','var') || isempty(titl)
            titl='';
        end
        if ~exist('anchor','var')
            anchor=0;
        end

        if (~isfield(obj.plotOpts,'debugFig') || isempty(obj.plotOpts.debugFig)) && (~exist('fnum','var') || isempty(fnum))
            obj.plotOpts.debugFig=nFn;
        else
            obj.plotOpts.debugFig=fnum;
        end
        figure(obj.plotOpts.debugFig);

        bTitleExists=isfield(obj.plotOpts,'debugsgtitl') && isvalid(obj.plotOpts.debugsgtitl) && ~isempty(obj.plotOpts.debugsgtitl) &&  isfield(obj.plotOpts.debugsgtitl,'String') && ~isempty(obj.plotOpts.debugsgtitl.String);
        if ~bTitleExists
            obj.plotOpts.debugsgtitl=sgtitle(titl);
        elseif bTitleExists && ~strcmp(obj.plotOpts.debugsgtitl.String,titl)
            clf();
            obj.plotOpts.debugsgtitl=sgtitle(titl);
        end

        k=anchor;
        subPlot([3,4],k,1);
        imagesc(obj.tstMap{k});
        formatImage();
        formatFigure('','','tst')

        for j = 2:3
            subPlot([3,4],k,j);
            imagesc(obj.gdMap{k}{j-1});
            formatImage();
            if k==(j-1) && k == 1
                titl='A L';
            elseif k==(j-1) && k == 2
                titl='A R';
            else
                titl=[];
            end
            formatFigure('','',titl);
        end
    end
    function debug_plot_end(obj,k,i)
        figure(obj.INDS{i}.plotOpts.debugFig);
        for k = 1:2
            subPlot([3,4],k,4)
            imagesc(obj.vet{k});
            formatImage();
            formatFigure('','','vet rolling')

            subPlot([3,4],3,k+1)
            imagesc(obj.INDS{i}.vet{k});
            formatImage();
            formatFigure('','','vet ind');
        end
        drawnow
    end
end
end
