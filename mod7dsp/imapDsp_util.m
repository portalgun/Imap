classdef imapDsp_util < handle
methods
%% HASH
    function obj=get_hash(obj)
        S=obj.get_struct(S);
        obj.hash=dataHash(S);
    end
    function obj=save_def(obj)
        dire=obj.get_dire();
        chkDirAll(dir,1);
        fname=[dire '_def_'];
        fnamey=[fname '.yaml'];
        imap=obj.get_struct();
        yaml.WriteYaml(fnamey,imap);
        save(fname,'imap');
    end
    function S=get_struct(obj)
        S=struct();
        for i = 1:length(obj.flds)
            fld=flds{i};
            S.(fld)=obj.(fld);
        end
        S.lvlCross=obj.lvlCross;
        S.hashes=obj.hashes;
        % THIS HASH DOES NOT GET ADDED TO HASHTABLE

    end
%% FROM
    function obj=get_ptch(obj)
        obj.ptch=load_patch(obj.pind);
    end
    function ptch=load_patch(obj,ind)
        fname=obj.get_patch_fname(ind);
        P=load(fname);
        ptch=P.ptch;
    end
    function fname=get_patch_fname(obj,ind);
        dire=obj.get_patch_dir();
        name=obj.get_patch_name(ind);
        fname=[dire name];
    end
    function obj=get_patch_dir(obj);
        dire=obj.ptch.get_directory_p(obj.hashes.database,obj.hashes.pch);
    end
    function name=get_patch_name(obj,pind);
        name=obj.fnames{ind};
    end
    function obj=get_patch_names(obj)
        obj.fnames=pch.get_name_index(obj.hashes.database,obj.hashes.pch);
        obj.nPtch=size(fnames,1);
    end
%% SAVE
    function obj=save(obj)
        obj.ptch.save();
    end
    function dire=get_dir(obj)
        dire=pch.get_dir_f(obj.hashes.database, obj.hashes.dsp);
    end
end
methods(Static=true)
    function dire=get_dir_f(database,hash)
        dire=ptch.get_directory_dsp(database,hash);
    end
end
end
