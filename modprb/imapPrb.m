classdef imapPrb < handle & imapPrb_plot & imapPrb_util
properties
    alias
    defName
    defFName

    edges
    counts
    imaps

    aliases
    database
    imgNums
    imgTypes
    imgNames
    nImgs

    hashTables

    nameDict

    N % histogram counts
    P % distribution (normalized histograms)
    C % Covariance
    Cimg
    R % correlation
end
properties(Hidden=true)
    fprog
    db
    cedges
    ccntrs
    selected
end
methods
    function obj=imapPrb(defName,aliases,types)

        %types
        if (~exist('types','var') || isempty(types,var)) && (exist('aliases','var') && ~isempty(aliases))
            types=cellstr( repmat('bin',length(aliases),1) );
        end


        if exist('types','var') && ~isempty(types)
            obj.imgTypes=types;
        end

        %defname
        if exist('defName','var') && ~isempty(defName)
            obj.defName=defName;
            obj.defFName=which(defName);
            if ~isempty(obj.defFName)
                obj.read_opts_from_file();
            end
        end

        % aliases
        if exist('aliases','var') && ~isempty(aliases)
            obj.aliases=aliases;
            obj.aliases2hashes(aliases);
        end

        %alias
        if isempty(obj.alias)
            obj.alias=sed('s',obj.defName,'^D_prb_','');
        end

        if obj.exist_fname()
            obj.load();
        end
        obj.get_nameDict();
        obj.get_imgNums();


        obj.load_all_edges();
        obj.load_all_counts();
        obj.load_all_hash_tables();

        obj.selected=1:length(obj.imgNames);
    end

    function obj=read_opts_from_file(obj)
        run(obj.defFName);

        if exist('alias','var') && ~isempty(alias)
            obj.alias=alias;
        end

        %imgNames
        if exist('imgNames','var') && ~isempty(imgNames)
            obj.imgNames=imgNames;
        elseif  exist('hashes','var') && ~isempty(hashes)
            obj.imgNames=hashes;
        else
            error('hashes do not exist in def file')
        end

        %database & imgTypes
        imgTypes=cell(size(obj.imgNames));
        for i = 1:length(obj.imgNames)
            [~, obj.database, obj.imgTypes{i}]=imapCommon.hash2alias(obj.imgNames{i});
            obj.database=obj.database{1};
        end

        % imgNums
        if exist('imgNums','var') && ~isempty(imgNums)
            obj.imgNums=imgNums;
        end



    end
    function obj=aliases2hashes(obj,aliases)
        obj.imgNames=cell(size(obj.imgTypes));
        for i = 1:length(aliases)
            [obj.imgNames{i}, obj.database] =imapCommon.alias2hash(aliases{i},obj.imgTypes{i});
        end
    end
    function obj=get_nameDict(obj)
        obj.nameDict=containers.Map(obj.imgNames,1:length(obj.imgNames));
    end
    function ojb=get_imgNums(obj)
        if isempty(obj.imgNums)
            obj.db=dbInfo(obj.database);
            obj.imgNums=obj.db.gdImages;
        end
        obj.nImgs=numel(obj.imgNums);
    end
    function obj=select(obj,inds)
        if ~all(ismember(inds,1:length(obj.imgNames)))
            error('Some invalid index entered')
        end
        obj.clear();
        obj.selected=inds;
    end
    function obj=clear(obj)
        obj.selected=[];
        obj.N=[];
        obj.P=[];
        obj.C=[];
        obj.R=[];
    end
    function obj=get_corr(obj)
        obj.get_joint_corr(obj.imgNames{obj.selected});
    end
    function obj=get_dist(obj)
        obj.get_joint_dist(obj.imgNames{obj.selected});
    end
    function obj=get_hist(obj)
        obj.get_joint_hist(obj.imgNames{obj.selected});
    end
end
methods(Access=private)
    function obj=get_joint_corr(obj,varargin)
        hashes=varargin;
        obj.C=cell(obj.nImgs,2);
        C=0; Mx=0; My=0; Vx=0; Vy=0; N=0;
        c=zeros(obj.nImgs,2);
        p=pr(obj.nImgs,1,'Getting covariances');
        for i = 1:obj.nImgs
        p.u();
        for k = 1:2
            I=obj.imgNums(i);
            imaps=obj.get_all_gen_imaps(I,k,hashes{:});
            c(i,k)=imapPrb.get_cov_img(imaps);
            [C,Mx,My,Vx,Vy,N]=imapPrb.get_cov_online(imaps,C,Mx,My,Vx,Vy,N);
        end
        end
        p.c();

        obj.C=C/(N-1);
        obj.R=obj.C./(sqrt(Vx)*sqrt(Vy));
        obj.Cimg=c;
    end
    function obj=get_joint_dist(obj,varargin)
        hashes=varargin;
        if isempty(obj.N)
            obj.get_joint_hist(hashes{:});
        end
        obj.P=obj.N./sum(obj.N,'all');
    end
    function N=get_joint_hist(obj,varargin)
        hashes=varargin;

        obj.N=0;
        p=pr(obj.nImgs,1,'Getting histograms');
        edges=cellfun(@(x) 1:numel(x),obj.edges,UO,false);


        if numel(hashes)==2
            ind1=obj.nameDict(hashes{1});
            ind2=obj.nameDict(hashes{2});
        end
        if isempty(obj.fprog)
            obj.fprog=nFn;
        end
        figure(obj.fprog);
        for i = 1:obj.nImgs
            %p.u();
            for k = 1:2
                I=obj.imgNums(i);
                imaps=obj.get_all_bin_imaps(I,k,hashes{:});
                [im,edges]=imapPrb.get_joint_hist_img(imaps, edges);
                obj.N=obj.N+im;

                if numel(hashes)==2
                    set(0,'CurrentFigure',obj.fprog);
                    imapPrb.plot_fun(obj.N, obj.edges{ind1},obj.edges{ind2});
                    drawnow
                end
            end
        end
        p.c();

    end
end
methods(Static=true)
    function data=convert_genImaps(genImaps)
        data=cell2mat(cellfun(@(x) x(:), transpose(genImaps), 'UniformOutput',false));
    end
    function C=get_cov_img(genImaps)
        data=imapPrb.convert_genImaps(genImaps);
        C=nancov(data(:,1),data(:,2));
        C=C(1);
    end
    function [C,Mx,My,Vx,Vy,N]=get_cov_online(genImaps,C,Mx,My,Vx,Vy,N)
        data=imapPrb.convert_genImaps(genImaps);

        for i = 1:size(data,1)
            if any(isnan(data(i,:)))
                continue
            end
            N=N+1;
            x=data(i,1);
            y=data(i,2);

            dx= x - Mx;
            dy= y - My;


            Mx=Mx+dx/N;
            My=My+dy/N;

            if N==1
                C=0;
                Vx=0;
                Vy=0;
            else
                C=C+dx*(y-My);
                Vx=(N-2)./(N-1)*Vx + 1/N*(dx)^2;
                Vy=(N-2)./(N-1)*Vy + 1/N*(dy)^2;
            end

        end
    end
% JOINT HIST
    function [N,Edges]=get_joint_hist_img(imaps,edges)
        imaps=imapPrb.format_imaps_for_histc(imaps);
        Edges=cell(2,1);
        if isempty(edges)
            %[N,edges,mid,loc]=histcn(imaps);
            [N,Edges{1},Edges{2}]=histcounts2(imaps(:,1),imaps(:,2));
        else
            %[N,edges,mid,loc]=histcn(imaps,edges{:});
            [N,Edges{1},Edges{2},loc]=histcounts2(imaps(:,1),imaps(:,2),edges{1},edges{2});
        end

        %[size(edges{1}); size(edges{2}); size(N)]

        %imagesc(N)
        %waitforbuttonpress
    end
    function new=format_imaps_for_histc(imaps)
        new=zeros(numel(imaps{1}),length(imaps));
        for i = 1:length(imaps)
            new(:,i)=imaps{i}(:);
        end
        ind=any(isnan(new),2);
        new(ind,:)=[];
    end
%% marginal
    function p=get_marginal_pop(counts)
        p=sum(counts,[3,2])./sum(counts,'all');
    end
    function p=get_marginal_img(counts,I)
        p=sum(counts(:,I,:),[3,2])./sum(counts(:,I,:),'all')
    end
%output = accumarray([firstbinnum(:), secondbinnum(:), thirdbinnum(:)], z(:), [], @(vals) {vals}, {});
%hist3
%histogram2
%histcounts2
end
end
