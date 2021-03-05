classdef imapPch_Tsrc < handle & imapPch_main
properties
    srcTable
end
properties(Constant=true)
    selKey={'P','fname','I','K','B','S','PctrRC','binVal','val'}
end
methods
    function obj=get_src_table(obj)
        if obj.exists_src_table()
            obj.load_src_table_p();
        else
            obj.gen_src_table();
            obj.save_src_table();
        end
    end

    function obj=gen_src_table(obj)
        obj.srcTable=cell(size(obj.fnames,1), size(imapPch_Tsrc.selKey,2));
        obj.srcTable(:,2)=obj.fnames;
        P=0;
        obj.p=pr(obj.nImg,1,'Generating src table');

        if obj.rndSd~=0
            rng(obj.rndSd);
        end
        for ii = 1:obj.nImg
            obj.p.u();
            obj.I=obj.imgNums(ii);
            for kk=1:2
                obj.k=kk;
                bStartK=1;

                for bb=1:obj.nBin
                    obj.B=bb;
                    obj.select_bin();
                    obj.select_nSmp();

                    for ss = 1:obj.nSmp
                        obj.S=obj.select_indInd(ss);
                        P=P+1;

                        obj.select_smpRC();
                        if bStartK
                            obj.get_gen();
                            bStartK=0;
                        end
                        obj.select_gen();

                        obj.srcTable{P,1}=P;
                        obj.srcTable{P,3}=obj.I;
                        obj.srcTable{P,4}=obj.k;
                        obj.srcTable{P,5}=obj.B;
                        obj.srcTable{P,6}=obj.S;
                        obj.srcTable{P,7}=obj.smpRC;
                        obj.srcTable{P,8}=obj.binVal;
                        obj.srcTable{P,9}=obj.val;
                    end
                end
            end
        end
        obj.p.c();
    end
    function out=exists_src_table(obj)
        fname=imapPch_Tsrc.get_src_table_fname(obj.hashes.database,obj.hash);
        out=exist([fname '.mat'],'file');
    end
    function obj=save_src_table(obj)
        dire=ptch.get_directory_p(obj.database,obj.hash);
        if ~exist(dire,'dir')
            mkdir(dire);
        end
        fname=imapPch_Tsrc.get_src_table_fname(obj.hashes.database,obj.hash);

        table=obj.srcTable;
        key=imapPch_Tsrc.selKey;

        save(fname,'table','key');
    end
    function obj=load_src_table_p(obj)
        [table,key]=imapPch_Tsrc.load_src_table(obj.database,obj.hash);

        obj.srcTable=table;
    end
end
methods(Static=true)
    function fname=get_src_table_fname(database,hash)
        dire=ptch.get_directory_p(database,hash);
        name='_src_';
        fname=[dire name];
    end
    function [table,key]=load_src_table(database,hash)
        fname=imapPch_Tsrc.get_src_table_fname(database,hash);
        load(fname);
        key=imapPch_Tsrc.selKey;

    end
end
end
