classdef binViewer < handle
properties
    alias
    database
    type
    hash

    COUNTS
    EDGES
    BINS
    nBIN

    groups
    counts
    edges
    bbins
    nbin

    nImg
    nK

    bLabel
    bLog
end
methods
    function obj=binViewer(alias,type)
        if exist('type','var') && ~isempty(type)
            obj.type=type;
        end
        if exist('alias','var') && ~isempty(alias)
            obj.alias=alias;
            obj.alias2hash();
        end
        obj.get_EDGES();
        obj.get_COUNTS();
        obj.get_bLog();

        obj.BINS=transpose(1:obj.nBIN);
        obj.groups=[obj.BINS, obj.BINS+1];
        obj.apply_groups();
    end
    function get_bLog(obj)

        opts=imapCommon.get_opts_from_def_f(obj.database,'bin',obj.hash);
        obj.bLog=opts.bLogBin;
    end
    function obj=get_EDGES(obj)
        switch obj.type
        case 'bin'
            obj.EDGES=imapBin.load_edges_f(obj.database, obj.hash);
        case 'smp'
            obj.EDGES=imapSmp.load_edges_f(obj.database, obj.hash);
        end

     end
    function obj=get_COUNTS(obj)
        switch obj.type
        case 'bin'
            obj.COUNTS=imapBin.load_counts_f(obj.database, obj.hash);
        case 'smp'
            obj.COUNTS=imapSmp.load_counts_f(obj.database, obj.hash);
        end
        obj.nBIN=size(obj.COUNTS,1);
        obj.nImg=size(obj.COUNTS,2);
        obj.nK=  size(obj.COUNTS,3);

    end
    function obj=set_groups(obj,groups)
        assert(all(groups(:,1) < groups(:,2)),'lower edges must be smaller than upper edges');
        t=transpose(groups);
        assert(all(diff(t(:))>=0),'edges must be increasing')

        obj.groups=groups;
        obj.apply_groups();
    end
    function obj=apply_groups(obj)
        obj.nbin=size(obj.groups,1);
        obj.counts=zeros(obj.nbin , size(obj.COUNTS,2), size(obj.COUNTS,3));
        obj.bbins=zeros(obj.nbin,2);
        for i = 1:obj.nbin
            b=obj.groups(i,1);
            e=obj.groups(i,2);

            obj.bbins(i,:)=[obj.EDGES(b) obj.EDGES(e)];
            obj.counts(i,:,:)=sum(obj.COUNTS(b:(e-1),:,:),1);
        end
        obj.edges=transpose(unique(obj.bbins));
        obj.bLabel=ismember(transpose(obj.EDGES),obj.edges);
    end
    function obj=plot_log(obj,I,k)
        bI=exist('I','var') && ~isempty(I) && isint(I);
        bK=exist('k','var') && ~isempty(k) && isint(k);

        if ~bI & ~bK
            counts=sum(obj.counts,[3 2]);
        elseif ~bI
            counts=sum(obj.counts(:,:,k),[2]);
        elseif ~bK
            counts=sum(obj.counts(:,I,:),[3]);
        end

        EDGES=find(ismember(obj.EDGES,obj.edges));
        if obj.bLog
            h=histogram('BinEdges',EDGES,'BinCounts',counts);
            edgeTicks=EDGES;
            edgeLabels=colVec(obj.edges);
        else
            XXX
        end
        binViewer.format_hist(h,edgeTicks,edgeLabels,EDGES);
        title('Log')
    end
    function obj=plot_linear(obj)
        bI=exist('I','var') && ~isempty(I) && isint(I);
        bK=exist('k','var') && ~isempty(k) && isint(k);

        if ~bI & ~bK
            counts=sum(obj.counts,[3 2]);
        elseif ~bI
            counts=sum(obj.counts(:,:,k),[2]);
        elseif ~bK
            counts=sum(obj.counts(:,I,:),[3]);
        end

        h=histogram('BinEdges',obj.edges,'BinCounts',counts);
        edgeLabels=colVec(obj.edges);
        edgeTicks=colVec(obj.edges);

        EDGES=find(ismember(obj.EDGES,obj.edges));
        binViewer.format_hist(h,edgeTicks,edgeLabels,EDGES);
        title('Linear')
    end
    function obj=alias2hash(obj)
        [obj.hash, obj.database] =imapCommon.alias2hash(obj.alias, obj.type);
    end
end
methods(Static=true)
    function format_hist(h,edgeTicks,edgeLabels,EDGES)
        h.FaceColor=[1 1 1];
        h.DisplayStyle='stairs';
        h.EdgeColor=[0 0 0];
        h.LineWidth=2;


        edgeNums=transpose(1:numel(edgeTicks));
        ticksl=arrayfun(@(x,y,z) [num2str(x,'%02i') ': ' num2str(y,'%02i') ': ' num2str(z)] ,edgeNums,transpose(EDGES),edgeLabels,UO,false);

        if max(edgeTicks)==inf
            d=(edgeTicks(end-1)-edgeTicks(1))*0.1;
            edgeTicks(end)=edgeTicks(end-1)+d;
        end
        xlim([edgeTicks(1)  edgeTicks(end)]);
        xticks(edgeTicks);
        xticklabels(ticksl);
        xtickangle(270);
        axis square;



    end
end
end
