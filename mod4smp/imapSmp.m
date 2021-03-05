classdef imapSmp < handle & imapCommon & LR & idxConversions & imapSmp_main & imapSmp_plot & imapSmp_Tall & imapSmp_Tcounts & imapSmp_Tedges & imapSmp_util
% TODO LOADING IN PRE
properties

    %INPUT
    imgType
    imgName

    % OPTS
    binNums
    PszXY
    rndSd
    nSmpPerBin
    bSampleDouble
    bBinOverlap
    bCPoverlap
    bSaveAsAll
    overlapPix
    priority

    % OUTPUT
    smp
    % SAMPLES
    % COUNTS
    countsBIL % [nBin x  nbin x nLandR]

    % FROM EDGES
    counts
    edges
end
properties (Hidden = true)
    SAMPLER
    I
    k
    B

    smpInd
    smpRC

    db
    xyz
    pht
    saveDir

    bin
    bap
    bibin

    iImapBins

    pixInd
    pixRC
    PctrInd
    PctrIndPri
    Pre

    vcounts

    cpLookup
    %indLookup

    nBin %nImg
    %nLandR

    binHist
    binHistImg
    binHistAll

    viewedBins
    rangeData

    %X
    %Y
    cumLandRcounts=[0 0]

    pkg
    TYPE='smp'
    p
    %blankmap
end
methods
    function obj=imapSmp(database,imgType,imgName,Opts,plotOpts,bRun)
        obj.database=database;
        if exist('imgType','var') || isempty(imgType)
            obj.imgType=imgType;
        end
        if exist('imgName','var') || isempty(imgName)
            obj.imgName=imgName;
        end
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        if ~exist('plotOpts','var') || isempty(plotOpts)
            plotOpts=struct();
        end
        if ~exist('bRun','var')
            bRun=1;
        end
        obj=obj.parse_Opts(Opts);
        obj.get_img_db_info();
        obj.parse_plotOpts_p(plotOpts);
        obj.get_hash();
        obj.save_def();

        obj.init_sampler();
        if bRun
            obj.main();
        end
    end
    function obj=parse_Opts(obj,Opts)
        P=imapSmp.get_parse();
        obj=parse(obj,Opts,P);

        obj.parse_LorRorB();

        if isempty(obj.bSampleDouble) && strcmp(obj.obj.LorRorB,'B')
            obj.bSampleDouble=1;
        elseif isempty(obj.bSampleDouble) && ~strcmp(obj.LorRorB,'B')
            obj.bSampleDouble=0;
        end

        obj.get_hash();
    end
    function obj=init(obj)
        binEdges=obj.get_bin_edges();
        if ~isempty(obj.binNums)
            obj.nBin=length(obj.binNums);
        else
            obj.binNums=1:length(binEdges);
            obj.nBin=length(binEdges);
        end

        obj.edges=binEdges(obj.binNums);
        obj.save_edges();

        obj.smpInd=cell(obj.nBin, obj.nImg, obj.nLandR);
        obj.smpRC =cell(obj.nBin, obj.nImg, obj.nLandR);
        if any(obj.imExists,'all')
            obj.load_counts();
        else
            obj.countsBIL=zeros(obj.nBin,max(obj.imgNums),obj.nLandR);
        end
        obj.blankmap=false(obj.db.IszRC);

    end
    function obj=init_sampler(obj)
        obj.SAMPLER=PctrSmp( obj.db.IszRC ...
                           , fliplr(obj.PszXY)...
                           , obj.overlapPix...
                           , obj.bCPoverlap...
                           , obj.nSmpPerBin...
                           , obj.rndSd...
        );
    end
end
methods(Static=true)
    function P = get_parse()
        P=   {  'LorRorB','B','isLorRorB'...
                ;'imgNums',[],'isallintorempty'...
                ;'PszXY',[50 50],'isallint2'...
                ;'rndSd',1,'isint'...
                ;'bSampleDouble',1,'isbinary'...
                ;'bBinOverlap',0,'isbinary'...
                ;'bCPoverlap',0,'isbinary'...
                ;'bSaveAsAll',0,'isbinary'...
                ;'overlapPix',0,'isallint1or2'...
                ;'nSmpPerBin',0,'isallint1'... % XXX
                ;'binNums',[],'isallintorempty'...
                ;'hashes',struct(),'isstruct_e'...
                ;'priority','cumu','ischar' ...
                };
    end
end
end
