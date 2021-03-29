classdef imapBin_util < handle & imapCommon_util & imapCommon_hash
methods
%% HASH
    function obj=get_hash(obj)
        obj=get_hash@imapCommon_hash(obj);
        obj.hashes.gen=obj.imgName;
        obj.hashes.vet=obj.vetName;
    end
%% GET
    function obj=get_image(obj)
        obj.img=imapCommon.get_imap_f(obj.database,obj.imgType,obj.imgName,obj.I,obj.k);
    end
    function obj=get_vet(obj)
        if isempty(obj.vetName)
            obj.vet=~isnan(obj.img);
        elseif ~isempty(obj.vetName)
            obj.vet=imapCommon.get_imap_f(obj.database,'vet',obj.vetName,obj.I,obj.k);
        end
    end
%% SAVE BIN
    function obj=save(obj)
        fname=obj.get_fname();
        imap=obj.bin;
        save(fname,'imap');
    end
    function imap=load(obj)
        imap=imapCommon.load_bin_f(obj.database,obj.hash,obj.I,obj.k)
    end
end
methods(Static=true)
    function imap=load_f(database,hash,I,k)
        fname=imapCommon.get_fname_f(database,'bin',hash, I, k);
        out=load(fname);
        imap=out.imap;
    end
    function re=get_files_regexp()
        re={

           ;'_aliases_.txt' ...
           ;'_def_.mat' ...
           ;'_def_.yaml' ...
           ;'[LR][0-9]{3}.mat'...
           ;'_counts_all_.mat'...
           ;'_counts_all_.yaml'...
           ;'_counts_.mat'...
           ;'_edges_.mat'...
           ;'_edges_.yaml'...
           ;'hist/'...
           ;'hist/[LRIAB][0-9]{4}.png'...
           };
    end
end
end
