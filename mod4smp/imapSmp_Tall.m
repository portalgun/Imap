classdef imapSmp_Tall < handle
methods
    function out=all_exists(obj)
        fname=[obj.get_fname_all() '.mat'];
        out=exist(fname,'file');
    end
    function fname=get_fname_all(obj)
        dire=imapCommon.get_directory_f(obj.database,'smp',obj.hash);
        name='_all_';
        fname=[dire name];
    end
    function save_smp_all(obj)
        smpRC=obj.smpRC;
        fname=obj.get_fname_all();
        save(fname,'smpRC');
    end
    function obj=load_smp_all(obj)
        fname=[obj.get_fname_all() '.mat'];
        load(fname);
        obj.smpRC=smpRC;
    end
end
methods(Static=true)
    function smpRC=get_smp_all(dbORalias,hash)

        if imapCommon.isalias(dbORalias)
            alias=dbORalias;
            hashes=imapCommon.alias2hashes(alias);
            database=hashes.database;
            hash=hashes.smp;
        else
            database=dbORalias;
        end

        %imap_Pch_main
        dire=imapCommon.get_directory_f(database,'smp',hash);
        fname=[dire '_all_.mat'];
        load(fname);
    end
end
end
