classdef dbViewer < handle
properties
    mods

    rootDBdir
    ptchDBdir

    fHashes=struct();
    dirs=struct();
    defs=struct();
    bEmpty=struct();
    bNoDef=struct();
    bIncomplete=struct();

end
methods
    function obj=dbViwer(database)
        obj.mods=imapCommon.modules();
        obj.rootDBdir=dbDirs(database);
        obj.ptchDBdir=dbDirs([database 'ptch']);

        obj.get_fHashes_all();
        obj.get_def_all();
        obj.get_empty_dirs_all();
        %obj.get_Incomplete_all():
    end
%%
    function obj=get_fHashes_all(obj)
        for i = 1:length(obj.mods)
            obj.get_fHashes(obj.mods{i});
        end
    end
    function obj=get_fHashes(obj,type)
        if isemmeber(type,{'pch','dsp','dmp'})
            dire=obj.ptchDBdir;
        else
            dire=obj.rootDBdir;
        end
        [f,ff]=dirsInDir(dire type);
        obj.fHashes.(type)=f;
        obj.dirs.(type)=ff;
    end
%%
    function get_def_all(obj)
        for i = 1:length(obj.mods)
            obj.load_def(obj.mods{i});
        end
    end
    function obj=load_def(obj,type)
        obj.bNoDef=false(size(obj.dirs.(type)));
        obj.defs.(type)=cell(size(obj.dirs.(type)));
        for i = 1:length(obj.dirs.(type))
            dire=obj.dirs.(type){i};
            file=[dire '_def_.mat'];
            if ~exist(file,'file')
                obj.bNoDef=1;
                continue
            end
            load(file);
            obj.defs.(type){i}=imap;
        end
    end
%%
    function obj=get_empty_dirs_all(obj)
        for i = 1:length(obj.mods)
            obj.get_empty(obj.mods{i});
        end
    end
    function obj=get_empty_dirs(obj,type)
        obj.bEmpty.(type)=false(size(obj.dirs.(type)));
        for i = 1:length(obj.dirs.(type))
            dire=obj.dirs.(type){i};
            files=filesInDir(dire);
            files=files(regExp(files,'^[^_].*mat'));
            obj.bEmpty.(type)(i)=isempty(files);
        end
    end
%%
    function obj=get_incomplete_all(obj)
        for i = 1:length(obj.mods)
            obj.get_incomplete(obj.mods{i});
        end
    end
    function obj=get_incomplete(obj,type)
        obj.bIncomplete.(type)=false(size(obj.dirs.(type)));
        for i = 1:length(obj.dirs.(type))
            if obj.bEmpty.(type){i}
                continue
            end
            files=filesInDir(dire);
            files=files(regExp(files,'^[^_].*mat'));
            if isemmeber(type,{'pch','dsp','dmp'})
                obj.bIncomplete.(type){i}=get_incomplete_ptch()
            else
                obj.bIncomplete.(type){i}=get_incomplete_imap()
            end
        end
        function get_incomplete_ptch()

            % XXX
        end
        function get_incomplete_imap()
            % XXX
        end
    end
%%
    function obj=get_aliases(obj)
        obj.aliases.(type)=cell(size(obj.dirs.(type)));
        obj.bNoAlias.(type)=false(size(obj.dirs.(type)));
        for i = 1:length(obj.dirs.(type))
            dire=obj.dirs.(type){i};
            file=[dire '_aliases_.txt'];
            if ~exist(file,'file')
                obj.bNoAlias=1;
                continue
            end
            obj.aliases(type){i}=file2cell(file);
        end
    end
end
end
