classdef imapSmp_Tcounts < handle
methods
    function out=counts_exists(obj)
        fname=imapSmp.get_counts_fname_f(obj.database,obj.hash);
        fname=[fname '.mat'];
        out=exist(fname,'file');
    end
    function obj=save_counts(obj)
        imapSmp.save_counts_f(obj.countsBIL,obj.database,obj.hash);
    end
    function obj=load_counts(obj)
        obj.countsBIL=imapSmp.load_counts_f(obj.database,obj.hash);
    end
end
methods(Static=true)
    function counts=load_counts_f(database,hash)
        fname=imapSmp.get_counts_fname_f(database,hash);
        in=load([fname '.mat']);
        counts=in.counts;
    end
    function []= save_counts_f(counts,database,hash)
        fname=imapSmp.get_counts_fname_f(database,hash);
        save(fname,'counts');
    end
    function fname=get_counts_fname_f(database,hash)
        dire=imapCommon.get_directory_f(database,'smp',hash);
        name=[ und 'counts' und ];
        fname=[dire name];
    end
end
end
