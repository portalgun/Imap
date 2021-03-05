classdef imapPch_util < handle
methods
    function out=exists_patch(obj)
        out=ptch.check_patch_exist_p(obj.hashes.database,...
                                 obj.hash,...
                                 obj.I,...
                                 obj.k,...
                                 obj.B,...
                                 obj.S);
    end
%% FROM
    function obj=get_smp_all(obj)
        obj.smpRCall=imapSmp_Tall.get_smp_all(obj.database,obj.hashes.smp);
        obj.nBin=size(obj.smpRCall,1);
        %obj.nImg=size(obj.smpRCall,2);
    end
    function obj=get_edges(obj)
        obj.edges=imapSmp.load_edges_f(obj.database,obj.hashes.smp);
    end
    function obj=get_gen(obj)
        obj.gen=obj.get_imap('gen',obj.hashes.gen);
    end
    function genOpts=get_genOpts(obj)
        genOpts=imapGen.load_genOpts(obj.database, obj.hashes.gen);
    end
%% SAVE
    function obj=save(obj)
        obj.ptch.save();
    end
    function fname=get_ptch_name(obj)
        fname=ptch.get_name_p(obj.I,obj.k,obj.B,obj.S);
    end
    function obj=reset_p(obj)
        imapPch.reset(obj.database,obj.hash);
    end
%% db
    function save_db(obj)
        db=obj.srcInfo.db();
        fname=obj.get_db_fname_p();
        save(fname,'db');
    end
    function fname=get_db_fname_p(obj)
        fname=imapPch.get_db_fname(obj.database,obj.hash);
    end
%% genOpts
    function save_genOpts(obj)
        genOpts=obj.genOpts;
        fname=obj.get_loc_genOpts_fname_p();
        save(fname,'genOpts');
    end
    function fname=get_loc_genOpts_fname_p(obj)
        fname=imapPch.get_loc_genOpts_fname(obj.database,obj.hash);
    end
end
methods(Static=true)
    function reset(database,hash)
        dire=ptch.get_directory_p(database,hash);
        files=filesInDir(dire);
        for i = 1:length(files)
            file=files{i};
            if regExp(file,'^_def_\..*') || regExp(file,'^_ind_\..*')
                continue
            elseif regExp(file,'.*\.mat$')
                delete([dire file]);
            end
        end
    end
    function fname=get_loc_genOpts_fname(database,hash)
        dire=ptch.get_directory_p(database,hash);
        fname=[dire '_genOpts_'];
    end
    function fname=get_db_fname(database,hash)
        dire=ptch.get_directory_p(database,hash);
        fname=[dire '_db_'];
    end
    function re=get_files_regexp()
        re={'_aliases_txt' ...
           ;'_def_.mat' ...
           ;'_def_.yaml' ...
           ;'_genOpts_.mat' ...
           ;'_ind_.mat' ...
           ;'_P_.mat' ...
           ;'_src_.mat' ...
           ;'[LR][0-9]{3}_[0-9]{3}_[0-9]{4}.mat'...
           };
    end
end
end
