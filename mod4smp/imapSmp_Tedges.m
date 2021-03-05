classdef imapSmp_Tedges < handle
methods
    function obj=save_edges(obj)
        imapSmp.save_edges_f(obj.edges,obj.database,obj.hash);
    end
    function obj=load_edges(obj)
        obj.edges=imapSmp.load_edges_f(obj.database,obj.hash);
    end
end
methods(Static=true)
    function []= save_edges_f(edges,database,hash)
        fname=imapSmp.get_edges_fname_f(database,hash);
        save(fname,'edges');
    end
    function edges=load_edges_f(database,hash)
        fname=imapSmp.get_edges_fname_f(database,hash);
        in=load([fname '.mat']);
        edges=in.edges;
    end
    function fname=get_edges_fname_f(database,hash)
        dire=imapCommon.get_directory_f(database,'smp',hash);
        name=[ und 'edges' und ];
        fname=[dire name];
    end
end
end
