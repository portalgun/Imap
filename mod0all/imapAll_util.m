classdef imapAll_util < handle
methods
    function ind=get_module_ind(obj,module)
        ind=find(ismember(obj.modules,module));
    end
    function obj=get_hash(obj)
        obj.hash=DataHash(obj.hashes);
    end
    function obj=save(obj)
        if ~isempty(obj.alias)
            name=obj.alias;
        else
            name=obj.hash;
        end
        rootDBdir=imapCommon.get_rootDBdir(obj.database);
        dire=[rootDBdir 'all' filesep];
        fname=[dire name];
        chkDirAll(dire,1);
        if exist(fname,'file')
            % XXX check overwrite -> do before
        else
            bContinue=1
        end
        if bContinue
            save(fname,'obj');
        end
        if ~isempty(obj.defName) && exist(obj.defName,'file')
            defname=which(obj.defName);
            dfname=[dire name '_DEF.m'];
            copyfile([defname],dfname);
        end
    end
end
end
