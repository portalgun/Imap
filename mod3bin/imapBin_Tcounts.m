classdef imapBin_Tcounts < handle
methods
    function obj=save_counts(obj)
        imapBin.save_counts_f(obj.counts,obj.database,obj.hash);
    end
    function obj=load_counts(obj)
        obj.counts=imapBin.load_counts_f(obj.database,obj.hash);
    end
end
methods(Static=true)
    function []= save_counts_f(counts,database,hash)
        fname=imapBin.get_counts_fname_f(database,hash);
        if size(counts,1) > 1 && size(counts,2) > 2
            bAll=0;
        else
            fname=sed('s', fname, '_$', '_all_');
            bAll=1;
        end

        save(fname,'counts');

        if ~bAll
            return
        end
        fnamey=[fname '.yaml'];
        yaml.WriteYaml(fnamey,counts);
    end
    function counts=load_counts_f(database,hash)
        fname=imapBin.get_counts_fname_f(database,hash);
        in=load([fname '.mat']);
        counts=in.counts;
    end
    function fname=get_counts_fname_f(database,hash)
        dire=imapCommon.get_directory_f(database,'bin',hash);
        name=[ und 'counts' und ];
        fname=[dire name];
    end
end
end
