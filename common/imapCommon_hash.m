classdef imapCommon_hash < handle
methods
    function obj=get_hash(obj)

        rmflds=imapCommon.get_hash_rmflds();

        S=obj2structPublic(obj);
        %flds=fieldnames(S);

        S=structRmFlds(S,rmflds);

        if isfield(S,'INDS')
            for i = 1:length(S.INDS)
                S.INDS{i}=obj2structPublic(S.INDS{i});
                S.INDS{i}=structRmFlds(S.INDS{i},rmflds);
            end
        end

        obj.hash=DataHash(S);
        %display(['Hash:' newline ' ' obj.hash]);

        if isprop(obj,'hashes')
            % XXX get previous hashes
            obj.hashes.database=obj.database;
            obj.hashes.(makeLowerCase(sed('s',class(obj),'^imap','')))=obj.hash;
        end
    end
end
methods(Static=true)
    function rmflds=get_hash_rmflds()
        rmflds={ 'database',...
                 'imgType', 'imgName', 'vetName', 'binName','smpName','pchName','dspName','selName',...
                 'bRmBorder',...
                 'vet','gen','bin','smp','pch','dsp','sel',...
                 'db',...
                 'hash', ...
                 'plotOpts',...
                 'imgNums','binNums','LorRorB',...
                 'countsIBL','counts','edges','cumLandRbinCounts',... % smp
                 'ptchDBdir', 'selKey', 'srcTable',...
                 'imExists','prog','p','xOpts',...
                 'SAMPLER'....
        };
    end
    function table=get_hash_table(database,type,hash)
        opts=imapCommon.get_opts_from_def_f(database,type,hash);
        table=opts.hashes;
    end
end
end
