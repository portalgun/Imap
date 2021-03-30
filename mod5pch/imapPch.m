classdef imapPch < handle & imapCommon & imapPch_main & imapPch_Tname & imapPch_util &  imapPch_Tsrc
% XXX long to short name
% make _ind_ a table
% progress
% progress plots
% check continue
% plot opts?
properties
    imgType
    imgName
    LorRorB

    PszXY
    PszRCbuff
    bStereo
    maxSmpPerImg
    limBinMin % -1 smallest bin. 0 off. > 0 set

    rndSd

    mapNames
    mskNames
    texNames

    db
end
properties(Hidden=true)
    ptchDBdir
    I
    k
    B

    fname
    fnames
    nSmp
    nBin
    P
    S=0;
    binVal
    Val
    ptch
    smpRC
    srcInfo
    src

    smpIndInd

    genOpts
    gen
    val
    smpRCall
    edges

    continueflag
    badPtchs
    p
    xyz
end
methods
    function obj=imapPch(database,imgType,imgName,Opts,plotOpts,bRun)
        obj.database=database;
        obj.imgType=imgType;
        obj.imgName=imgName;
        if exist('imgName','var')
            obj.imgName=imgName;
        end
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        if ~exist('plotOpts','var') || isempty(plotOpts)
            plotOpts=struct();
        end
        if ~exist('bRun','var') || isempty(bRun)
            bRun=1;
        end

        obj=obj.parse_Opts(Opts);
        obj.get_img_db_info();
        obj.get_hash();
        obj.parse_plotOpts_p(plotOpts);
        obj.save_def();

        obj.init_src_info();
        obj.get_genOpts();

        if bRun
            obj.main();
        end
    end
    function obj=parse_Opts(obj,Opts)
        P=imapPch.get_parse();
        obj=parse(obj,Opts,P);

        if obj.maxSmpPerImg==0
            obj.maxSmpPerImg=inf;
        end
        if isempty(obj.rndSd) && obj.maxSmpPerImg == inf
            obj.rndSd=0;
        elseif isempty(obj.rndSd)
            obj.rndSd=1;
        end
    end
    function obj=init_src_info(obj)
        obj.srcInfo=srcInfo(obj.hashes.database,...
                            obj.hashes,...
                            0,0,{[0 0],[0 0]},...
                            0,0,0,0,0,...
                            obj.db, ...
                            obj.genOpts);
    end
end
methods(Static=true)
    function P=get_parse()
        P  ={'LorRorB','B','isLorRorB'...
            ;'imgNums',[],'isallintorempty'...
            ;'maxSmpPerImg',0,'isallint1' ...
            ;'limBinMin',0,'isnumeric' ...
            ;'rndSd',[],'isint1' ...
            ;'ptchDBdir',[],'ischar'...
            ;'PszXY',[],'isallint2'...
            ;'PszRCbuff',[],'isallint2'...
            ;'mapNames',{'xyz','pht'},'iscell'...
            ;'mskNames',{},'iscell'...
            ;'texNames',{},'iscell'...
            ;'bStereo',1,'isbinary'...
            ;'hashes',struct(),'isstruct_e'...
            };
    end

end
end
