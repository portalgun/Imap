classdef imapGen_util < handle & imapCommon_util
methods
%% FROM
    %%
    function im=get_images(obj)
        im=getImgs(obj.database,'img',obj.mapsNeeded,obj.I);
    end
    function obj=save(obj);
        fname=obj.get_fname();
        imap=obj.gen;
        save(fname,'imap');
    end
end
methods(Static=true)
    function img=load_f(database,imgName,I,k)
        img=imapCommon.get_imap_f(database,'gen',imgName,I,k);
    end
    function genOpts=load_genOpts(database,hash)
        imap=imapCommon.get_opts_from_def_f(database,'gen',hash);
        genOpts=imap.genOpts;
    end
    function re=get_files_regexp()
        re={'_aliases_.txt' ...
           ;'_def_.mat' ...
           ;'_def_.yaml' ...
           ;'[LR][0-9]{3}.mat'...
           ;'_fig_/'...
           ;'_fig_/[LR][0-9]{4}.png'...
           };
    end
end
end
