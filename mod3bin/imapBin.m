classdef imapBin < handle & imapCommon & LR & imapBin_main & imapBin_plot & imapBin_Tcounts & imapBin_Tedges & imapBin_util
% TODO
% plot pht
% plot gen
properties
    %INPUT
    imgType
    imgName
    vetName
    %OPTS
    nBin
    bLogBin

    %OUTPUT
    edges
    counts
end
properties(Hidden = true)
    db
    I
    k

    img
    vet
    bin

    blankmap
    bVet

    TYPE='bin'
    bGetEdges
end
methods
    function obj=imapBin(database,imgType,imgName,vetName,Opts,plotOpts,bRun)
    % imType & imgName likely gen
        obj.database=database;
        if exist('imgType','var')
            obj.imgType=imgType;
        end
        if exist('imgName','var')
            obj.imgName=imgName;
        end

        if exist('vetName','var')
            obj.vetName=vetName;
        end

        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        if ~exist('plotOpts','var') || isempty(plotOpts)
            plotOpts=struct();
        end
        if ~exist('bRun','var') || isempty(bRun)
            bRun=0;
        end
        obj.hashes.database=obj.database;
        obj.hashes.vet=obj.vetName;
        obj.hashes.gen=obj.imgName;

        obj.get_img_db_info(); %get iszrc
        obj=obj.parse_Opts(Opts);
        obj.get_img_db_info(); %fix imgnums
        obj.get_hash();
        obj.parse_plotOpts_p(plotOpts);
        obj.save_def();

        obj.pre_check();
        if bRun
            obj.main();
        end
    end
    function obj=parse_Opts(obj,Opts)
        P=imapBin.get_parse();
        obj=parse(obj,Opts,P);

        obj.parse_LorRorB();


        obj.bVet=1;
        if isempty(obj.vetName)
            obj.bVet=0;
            obj.vet=ones(obj.db.IszRC);
        end
    end
    function obj=pre_check(obj)

        if ~isempty(obj.edges)
            obj.bGetEdges=0;
            return
        else
            fname=imapBin.get_edges_fname_f(obj.database,obj.hash);
            obj.bGetEdges=exist([fname '.mat'],'file')~=2;
        end
        if ~obj.bGetEdges
            obj.load_edges();
        end
    end
end
methods(Static=true)
    function P=get_parse()
        P={
          ;'LorRorB',[],'isLorRorB' ...
          ;'imgNums',[],'isallintorempty' ...
          ;'nBin',   [],'isint_e' ...
          ;'bLogBin',[],'isbinary_e' ...
          ;'edges',  [],'isnumeric_e' ...
        };
    end
end
end
