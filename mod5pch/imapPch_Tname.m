classdef imapPch_Tname < handle & imapPch_main
methods
    function obj=get_name_index(obj)
        if obj.exists_name_index()
            obj.load_name_index_p();
        else
            obj.gen_name_index();
            obj.save_name_index();
        end
    end
    function obj=gen_name_index(obj)
        obj.fnames=cell(0,1);
        obj.p=pr(obj.nImg,1,'Generating name index');
        if obj.rndSd~=0
            rng(obj.rndSd);
        end
        for ii = 1:obj.nImg
            obj.p.u();
            obj.I=obj.imgNums(ii);
            for kk=1:2
                obj.k=kk;
                for bb=1:obj.nBin
                    obj.B=bb;
                    obj.select_nSmp();
                    for ss = 1:obj.nSmp
                        obj.S=obj.select_indInd(ss);
                        obj.fnames{end+1,1}=obj.get_ptch_name();
                    end
                end
            end
        end
        obj.p.c();
    end
    function out=exists_name_index(obj)
        fname=ptch.get_name_index_fname(obj.hashes.database,obj.hash);
        out=exist([fname '.mat'],'file');
    end
    function obj=save_name_index(obj)

        dire=ptch.get_directory_p(obj.hashes.database,obj.hash);
        if ~exist(dire,'dir')
            mkdir(dire)
        end

        fname=ptch.get_name_index_fname(obj.hashes.database,obj.hash);
        idx=obj.fnames;
        save(fname,'idx')
    end
    function obj=load_name_index_p(obj)
        fname=ptch.get_name_index_fname(obj.hashes.database,obj.hash);
        load(fname)
        obj.fnames=idx;
    end
end
methods(Static=true)
    function fname=get_name_index_fname(database,hash)
        dire=ptch.get_directory_p([],hash,database);
        name='_ind_';
        fname=[dire name];
    end
    function name=get_name_index_name()

    end
end
end
