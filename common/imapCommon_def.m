classdef imapCommon_def < handle
methods
    function obj=get_opts_from_def(obj)
        type=obj.get_type();
        Opts=imapCommon.get_opts_from_def_f(obj.database,type,obj.hash);
        flds=fieldnames(imap);
        for i = 1:length(flds)
            fld=flds{i};
            if isprop(obj,fld)
                obj.(fld)=imap.(fld);
            end
        end
    end
%% UITL
    function obj=save_def(obj)
        data=obj2structPublic(obj);
        rmflds=imapCommon.get_def_rmflds();
        imap=structRmFlds(data,rmflds);
        if isfield(imap,'INDS') && iscell(imap.INDS)
            for i = 1:length(imap.INDS)
                imap.INDS{i}=obj2structPublic(imap.INDS{i});
                imap.INDS{i}=structRmFlds(imap.INDS{i},rmflds);
            end
        end
        imap.hashes=obj.hashes;

        type=obj.get_type();

        fname=imapCommon.get_def_fname_f(obj.database,type,obj.hash);
        dir=filePartsSane(fname);
        chkDirAll(dir,1);
        fnamey=[fname '.yaml'];
        yaml.WriteYaml(fnamey,imap);

        save(fname,'imap');
    end
end
methods(Static=true)
    function imap=get_opts_from_def_f(database,type,hash)
        fname=imapCommon.get_def_fname_f(database,type,hash);
        load(fname);
    end
    function fname=get_def_fname_f(database,type,hash)
        dire=imapCommon.get_directory_f(database,type,hash);
        name=[ und 'def' und ];
        fname=[dire name];
    end
    function rmflds=get_def_rmflds()
        rmflds=imapCommon.get_hash_rmflds();
        % NOTE hashes added later and last
    end
    function [bSameProps,bSameOpts,bSameHashes]=check_def_compat(database1,mod1,hash1, database2,mod2,hash2)
        bSameProps=1;
        bSameOpts=1;
        bSameHashes=1;

        fname1=imapCommon.get_def_fname_f(database1,mod1,hash1);
        fname2=imapCommon.get_def_fname_f(database2,mod2,hash2);

        if ~exist(fname1,'file')
            return
        elseif ~exist(fname2,'file')
            error('Second def file doesn''t exist')
        end

        opts1=imapCommon.get_opts_from_def_f(database1,mod1,hash1);
        opts2=imapCommon.get_opts_from_def_f(database2,mod2,hash2);
        flds=unique([fieldnames(opts1); fieldnames(opts2)]);

        if ~strcmp(mod1,mod2)
            error('Modules are different and therefore unable to switch')
        end
        if ~strcmp(database1,database2)
            error('Databases are different and therefore unable to switch')
        end

        modName=['imap' makeUpperCase(mod1(1)) mod1(2:end)];

        bVersDiff=0;
        rmInd=[];
        for i = 1:length(flds)
            fld=flds{i};
            if ~ismember(fld,properties(modName))
                rmInd=[rmInd; i];
                bSameProps=0;
            elseif ~isfield(opts1,fld) || ~isfield(opts2,fld)
                rmInd=[rmInd; i];
                bSameProps=0;
            end
        end
        for i = 1:length(rmInd)
            fld=flds(rmInd(i));
            if isfield(opts1,fld)
                opts1=rmfield(opts1,fld);
            end
            if isfield(opts1,fld)
                opts2=rmfield(opts2,fld);
            end
        end
        hashes1=opts1.hashes;
        hashes2=opts2.hashes;
        hashes1.(mod1)=[];
        hashes2.(mod1)=[];
        opts1=rmfield(opts1,'hashes');
        opts2=rmfield(opts2,'hashes');

        bSameOpts=isequal(opts1,opts2);
        bSameHashes=isequal(opts1,opts2);
    end
end
end
