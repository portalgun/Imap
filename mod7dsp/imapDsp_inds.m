classdef imapDsp_inds < handle
methods
%% ALL IND OPTS
    function obj=init_all_inds(obj)
        obj.get_all_indOpts();
        obj.get_all_indHashes();
        obj.get_all_indDirs();
        obj.init_all_ind_Dirs();
        obj.save_all_ind_def();
    end
    function obj=get_all_indOpts(obj)
        obj.inOptsAll=cell(obj.N,1);
        for i=1:obj.N
            obj.get_ind_opts(i);
            obj.indOptsAll{i}=obj.indOpts;
        end
    end
    function obj=get_ind_opts(obj,ind)
        flds=obj.flds;
        obj.indOpts=struct();
        for i = 1:length(flds)
            fld=flds{i};
            obj.indOpts.(fld)=struct_select(obj.(fld),i);
        end

        function s=struct_select(S,ind)
            s=struct();
            flds=fieldnames(S);
            for i = 1:length(flds)
                fld=flds{i};
                if size(S.(fld),1)==1
                    s.(fld)=S.(fld);
                    % NOTE, single row fields are not expanded
                else
                    s.(fld)=S.(fld)(ind,:);
                end
            end
        end
    end
    function obj=get_all_indHashes(obj)
        obj.indHashesAll=cell(obj.N,1);
        for i = 1:obj.N
            S=obj.indOptsAll{i};
            S.hashes=obj.hashes;
            obj.indHashesAll{i}=DataHash(S);
        end
    end
    function obj=get_all_indDirs(obj)
        obj.indDirAll=cell(obj.N,1);
        for i = 1:obj.N
            obj.indDirAll{i}=obj.get_dir_ind(i);
        end
    end
    function obj=init_all_ind_dirs(obj)
        dire=[imapCommon.get_rootDBdir(hashes.database) 'dsp'];
        chkDirAll(dire);
        for i = 1:obj.N
            dire=obj.indDirAll{i};
            if ~exist(dire,'dir')
                mkdir(dire);
            end
        end
    end
    function obj=save_all_ind_def(obj)
        for i = 1:obj.N
            obj.indDirAll{i}=obj.get_dir_ind(i);
            fname=[dire '_def_' ];
            fnamey=[fname '.yaml'];
            imap=obj.indOptsAll{i};
            yaml.WriteYaml(fnamey,imap);

            save(fname,'imap');
        end
    end
%% SELECT IND OPTS
    function obj=select_ind_opt(obj,i)
        obj.indOpts=obj.indOptsAll{i};
        obj.select_ind_display();
    end
    function obj=select_ind_display(obj)
        name=obj.indOpts.display;
        if isa(name,'DISPLAY')
            return
        end

        ind=ismember(obj.udisplaynames,name);
        obj.indOpts.display=obj.udisplays(ind);
    end
    function obj=select_ind_hash(obj)
        obj.indHashes=obj.hashes;
        obj.indHashes.dsp=obj.indHashesAll{i};
        % XXX indHashes
    end
%% TABLE
    function save_all_ind_table(obj)
        for i = 1:N
            table=obj.get_ind_table();
            fname=obj.get_ind_table_fname(i);
            save(fname,'table');
        end
    end
    function table_ind=get_ind_table(obj)
        hashind=ismember(obj.key,'hash');
        table_ind=obj.table( ismember(obj.table(:,hashind), obj.indHashesAll{ind}),:);
    end
    function []=save_ind_table(obj,ind)
        fname=obj.get_ind_table_fname(ind);
        % XXX table, key
        save(fname,'table','key');
    end
    function fname=get_ind_table_fname(obj,ind)
        dire=imapDsp.get_ind_table_fname_f(obj.hashes.database,obj.indHashesAll{ind});
        name='_table_';
        fname=[dire name];
    end
%% UTIL
    function dire=get_dir_ind(obj,ind)
        dire=pch.get_ind_dir_f(obj.hashes.database, obj.indHashesAll{ind});
    end
end
methods(Static=true)
%% TABLE
    function dire=load_ind_table_f(database,indhash)
        fname=imapDSP.get_table_ind_fname_f(database,indHash);
        load(fname);
    end
    function fname=get_ind_table_fname_f(database,indHash)
        dire=ptch.get_directory_dsp_ind_p(database,indHash);
        name='_table_';
        fname=[dire name];
    end
%% UTIL
    function dire=get_ind_dir_f(database,indhash)
        bdir=pch.get_directory_ind_dsp(database,indhash);
    end
end
end
