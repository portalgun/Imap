classdef imapSmp_util < handle
methods
%% FROM
    function obj=get_smp_all_p(obj)
        obj.smpRCAll=imapSmp.get_smp_all(obj.database,obj.hashes.smp)
    end
    function obj=get_range_data(obj)
        bFlag=0;
        if isempty(obj.db)
            obj.xyz=XYZ(obj.database,obj.I);
            obj.db=obj.xyz.db;
            bFlag=1;
        else
            % REUSE DB INFO
            obj.xyz=XYZ(obj.database,obj.I,obj.db);
        end
        obj.xyz.get_cpLookup_bi();

    end
    function counts=get_bin_counts(obj)
        counts=imapBin.load_counts_f(obj.database,obj.hashes.bin);
    end
    function im=get_bin_img(obj)
        obj.bin=getImg(obj.database,obj.imgType,obj.imgName,obj.I);
    end
    function edges=get_bin_edges(obj)
        edges=imapBin.load_edges_f(obj.database,obj.hashes.bin);
    end
%% SAVE
    function obj=save(obj)
        RCL=vertcat(obj.smpInd{:,obj.I,1});
        RCR=vertcat(obj.smpInd{:,obj.I,2});
        fnameL=imapCommon.get_fname_f(obj.database,'smp',obj.hash,obj.I,'L');
        fnameR=imapCommon.get_fname_f(obj.database,'smp',obj.hash,obj.I,'R');

        imap=obj.blankmap;
        imap(RCL)=true;
        save(fnameL,'imap');

        imap=obj.blankmap;
        imap(RCR)=true;
        save(fnameR,'imap');
    end
end
methods(Static=true)
    function re=get_files_regexp()
        re={'_aliases_.txt' ...
           ;'_def_.mat' ...
           ;'_def_.yaml' ...
           ;'[LR][0-9]{3}.mat'...
           ;'_counts_.mat'...
           ;'_edges_.mat'...
           ;'_all_.mat'...
           ;'_fig_/'...
           ;'_fig_/[ILR][0-9]{4}.png'...
           };
    end
end
end
