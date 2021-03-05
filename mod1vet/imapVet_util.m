classdef imapVet_util < handle
methods
    function obj=get_tstMaps(obj,i)
        I=obj.imgNums(i);

        for l = 1:obj.nImap
            obj.INDS{l}.tstMap=cell(2,1);
        end

        for l = 1:obj.nImap
            for kk = 1:obj.nLandR
                obj.INDS{l}.get_tstMap(I, kk);
            end
        end
    end
    function obj=get_range_data(obj)
        bFlag=0;
        if isempty(obj.db)
            xyz=XYZ(obj.database,obj.I);
            obj.db=xyz.db;
            bFlag=1;
        else
            % REUSE DB INFO
            xyz=XYZ(obj.database,obj.I,obj.db);
        end
        if obj.bCP && strcmp(obj.LorRorB,'B')
            xyz.get_CPs_all_bi();
            %xyz.get_cpLookup_bi();
        elseif obj.bCP
            xyz.get_CPS_all(obj.LorRorB);
            %xyz.get_cpLookup(obj.LorRorB);
        end
        %xyz.cpLookup

        for i=1:obj.nImap
            if obj.INDS{i}.bVetCP
                obj.INDS{i}.xyz=xyz;
            end
        end

    end
    function obj=save_vet(obj);
        if obj.LorRorB=='B'
            kk=[1 2];
        else
            kk=obj.k
        end
        for i = 1:length(kk)
            fname=imapCommon.get_fname_f(obj.database,'vet',obj.hash, obj.I, i);
            imap=obj.vet{i};
            save(fname,'imap');
        end
    end
end
methods(Static=true)
    function re=get_files_regexp()
        re={
           ;'_aliases_.txt' ...
           ;'_def_.mat' ...
           ;'_def_.yaml' ...
           ;'[LR][0-9]{3}.mat'...
           ;'_fig_/'...
           ;'_fig_/[LR][0-9]{4}.png'...
           };
    end
end
end
