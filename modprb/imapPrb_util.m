classdef imapPrb_util < handle
methods
    function save(obj)

        dire=imapPrb.get_directory_p(obj.database, obj.alias);
        chkDirAll(dire,1);

        fname=imapPrb.get_fname_p(obj.database, obj.alias);

        % XX number


        imgNames=obj.imgNames(obj.selected);
        imgTypes=obj.imgTypes(obj.selected);
        N=obj.N;
        P=obj.P;
        C=obj.C;
        Cimg=obj.Cimg;
        R=obj.R;
        save(fname,'imgNames','imgTypes','N','P','C','Cimg','R');
    end
    function out=exist_fname(obj)
        out=imapPrb.exist_fname_p(obj.database,obj.alias);
    end
    function obj=load(obj)
        fname=imapPrb.get_fname_p(obj.database,obj.alias);
        fname=[fname '.mat'];

        load(fname)

        obj.N=N;
        obj.P=P;
        obj.C=C;
        obj.Cimg=Cimg;
        obj.R=R;
    end
end
methods(Hidden=true)
%% GET IMAP
    function load_all_hash_tables(obj)
        obj.hashTables=cell(size(obj.imgNames));
        for i = 1:length(obj.imgNames)
            hash=obj.imgNames{i};
            type=obj.imgTypes{i};
            obj.hashTables{i}=obj.load_hash_tables(hash,type);
        end
    end
    function table=load_hash_tables(obj,hash,type)
        if iscell(type)
            type=type{1};
        end
        table=imapCommon.get_hash_table(obj.database,type,hash);
    end
    function imaps=get_all_bin_imaps(obj,I,k,varargin)
        hashes=varargin;
        imaps=cell(length(hashes),1);
        for i = 1:length(hashes)
            hash=hashes{i};
            imaps{i}=obj.load_bin_imap(I,k,hash);
        end
    end
    function imaps=get_all_gen_imaps(obj,I,k,varargin)
        hashes=varargin;
        imaps=cell(length(hashes),1);
        for i = 1:length(hashes)
            hash=hashes{i};
            ind=ismember(hash,obj.imgNames);
            hashgen=obj.hashTables{ind}.gen;
            imaps{i}=obj.load_gen_imap(I,k,hashgen);
        end
    end
%% Get  EDGES
    function edges=get_all_edges(obj,varargin)
        hashes=varargin;
        edges=cell(length(hashes),1);
        for i = 1:length(hashes)
            hash=hashes{i};
            edges{i}=obj.get_edges(hash);
        end
    end
    function edges=get_edges(obj,hash)
        ind=obj.nameDict(hash);
        edges=obj.edges{ind};
    end
%% GET COUNTS
    function counts=get_all_counts(obj,I,k,varargin)
        hashes=varargin;
        counts=cell(length(hashes),1);
        for i = 1:length(hashes)
            hash=hashes{i};
            counts{i}=get_counts(hash,I,k);
        end
    end
    function counts=get_counts(obj,hash,I,k)
        ind=obj.nameDict(hash);
        counts=obj.counts{ind,I,k};
    end
%% LOAD IMAP
    function imap=load_bin_imap(obj,I,k,hash)
        imap=imapBin.load_f(obj.database,hash,I,k);
    end
    function imap=load_gen_imap(obj,I,k,hash)
        imap=imapGen.load_f(obj.database,hash,I,k);
    end
%% LOAD EDGES
    function obj=load_all_edges(obj)
        for i = 1:length(obj.imgNames)
            type=obj.imgTypes{i};
            hash=obj.imgNames{i};
            obj.edges{i}=obj.load_edges(type,hash);
        end
    end
    function edges=load_edges(obj,type,hash)
        obj.counts=cell(length(obj.imgNames),1);
        if iscell(type)
            type=type{1};
        end
        switch type
                case 'bin'
                    edges=obj.load_bin_edges(hash);
                case 'smp'
                    edges=obj.load_smp_edges(hash);
                case 'sel'
                    edges=obj.load_sel_edges(hash);
        end
    end
    function edges=load_smp_edges(obj,hash)
        edges=imapSmp.load_edges_f(obj.database,hash);
    end
    function edges=load_bin_edges(obj,hash)
        edges=imapBin.load_edges_f(obj.database,hash);
    end
    function edges=load_sel_edges(obj,hash)
        edges=imapBin.load_edges_f(obj.database,hash);
    end
%% LOAD COUNTS
    function obj=load_all_counts(obj)
        obj.counts=cell(length(obj.imgNames),1);
        for i = 1:length(obj.imgNames)
            type=obj.imgTypes{i};
            hash=obj.imgNames{i};
            obj.counts{i}=obj.load_counts(type,hash);
        end
    end
    function obj=load_counts(obj,type,hash)
        if iscell(type)
            type=type{1};
        end
        switch type
                case 'bin'
                    counts=obj.load_bin_counts(hash);
                case 'smp'
                    counts=obj.load_smp_counts(hash);
                case 'sel'
                    counts=obj.load_sel_counts(hash);
        end
    end
    function counts=load_smp_counts(obj,hash)
        counts=imapSmp.load_counts_f(obj.database,hash);
    end
    function counts=load_bin_counts(obj,hash)
        counts=imapBin.load_counts_f(obj.database,hash);
    end
    function counts=load_sel_counts(obj,hash)
        counts=imapBin.load_counts_f(obj.database,hash);
    end

end
methods(Static=true)
    function out=exist_fname_p(database,alias)
        fname=imapPrb.get_fname_p(database,alias);
        out=exist([fname '.mat'],'file')==2;
    end
    function fname=get_fname_p(database,alias)
        dire=imapPrb.get_directory_p(database,alias);
        fname=[dire '_stats_'];
    end
    function dire=get_directory_p(database,alias)
        rootDBdir=imapCommon.get_rootDBdir(database);
        dire=[rootDBdir 'prb' filesep  alias filesep];
    end
end
end
