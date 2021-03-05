classdef imapSel < handle & imapSel_main & imapSel_Tblk & imapSel_Tlvl & imapSel_Tsel & imapSel_util
% package ptch into ptchs: dmp,test,train,pilot
% XXX
% save def
% save/load lvltable
% save/load blktable
% save/load seltable
% counts
% review weight procedure
% parse lvlStruct / get lvlTable?
% change modes according to Eobj
% repeats
% pr
% progress plots?
% plotOpts?
%  check continue
properties
    repeats
        % full  - sample once for all
        % rnd   - sample w/ replacement
        % none  - sample w/out replacement
        %
        %BETWEEN
        % modes
        % stds
        % trl
        % intrvls
    initLvl
        %1 just indeces
        %2 minimal patches
        %3 full patches

    prjInfo
        %prjCode
        %imgDTB
        %natORflt
        %imgDim
        %method
        %prjInd


    %optsions
    modes
    nBlkPerLvl % number of partial curves
    % one of these
    nIntrvlPerTrl % =nStrimPerTril, = nCmpPerTrl + 1
    nCmpPerTrl
    % one of these
    nTrl
    nTrlPerLvl % number of points contituating a curve
    nTrlPerBlk

    %computed
    nLvlsAll   % all lvls available
    nLvls      % total number of lvls used - set
    nStd       % number of curves
    nCmpPerLvl % number of points on psy curve

    creationDate
    rndSd
    blkSd

    bEobj
    % explicit to E - pass, subjs, sometimes prjInd
    hash
    bDsp;
end
properties(Hidden = true)
    Eobj
    PTCHS
    hashes

    lvlTable

    dspTable
    dspKey
    blkTable
    blkKey
    selTable
    selKey

    nImg
    I
        %columns
        %   P
        %   fname
        %   trl
        %   cmpNum
        %   intrvl
        %   dspLvl
        %   binLvl
        %   imgNum
        %   k
end
methods
    function obj=imapSel(hashes,imgType,imgName,Opts,plotOpts,bRun)
        obj.hashes=hashes;
        obj.imgType=imgType;
        obj.imgName=imgName;
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

        % HASHES
        obj.gen_name_base(); % AKA "hash"
        obj.hashes.sel=obj.hash;
        if strcmp(obj.imgType,'dsp')
            obj.hashes.dsp=obj.imgName;
        elseif strcmp(obj.imgType,'pch')
            obj.hashes.pch=obj.imgName;
        end


        %obj.parse_plotOpts_p();
        %obj.save_def();

        if bRun
            obj.main()
        end
    end
    function obj=parse_Opts(obj,Opts)
        if isfield(Opts,'imgNums')
            Opts=rmfield(Opts,'imgNums');
        end
        if isfield(Opts,'LorRorB')
            Opts=rmfield(Opts,'LorRorB');
        end
        if isfield(Opts,'hashes')
            if isempty(obj.hashes)
                obj.hashes=Opts.hashes;
            end
            Opts=rmfield(Opts,'hashes');
        end

        P=imapSel.get_parseOPts();
        obj=parse(obj,Opts,P);

        obj.nTrlPerBlk=obj.nTrl/obj.nBlk; % XXX
        obj.nCmpPerTrl=obj.nIntrvlPerTrl-1;
        rng(obj.rndSd);
        obj.blkSd=randi(2^32,1);
        obj.lvlTable=get_lvl_table(obj.stdStruct);
        obj.nLvl=size(obj.lvltable.inds,1);
        obj.nTrlPerLvl=obj.nTrl/obj.nLvl;


    end
%%%
end
methods (Static=true)

%% E
    function prjInfo=format_prjInfo(prjInfo)
        prjInfo.prjCode  = Eobj.parse_prjCode(prjInfo.prjCode);
        prjInfo.imgDTB   = Eobj.parse_imgDTB(prjInfo.imgDTB);
        prjInfo.natORflt = Eobj.parse_natORflt(prjInfo.natORflt);
        prjInfo.imgDim   = Eobj.parse_imgDim(prjInfo.imgDim);
        prjInfo.method   = Eobj.parse_method(prjInfo.method);
        prjInfo.prjInd   = Eobj.parse_prjInd(prjInfo.prjInd);
    end
    function P=get_parseOpts();
        P={...
            ;'modes', [],    'isallint_e'...
            ;'bEobj',      1,'isbinary_e'...
            ...
            ;'prjCode'      [], 'ischar' ...
            ;'imgDTB'      [], 'ischar' ...
            ;'natORflt'    [], 'ischar' ...
            ;'imgDim'      [], 'ischar' ...
            ;'method'      [], 'ischar'...
            ;'prjInd'      [],'ischar_e'...
            ;'alias'       [],'ischar_e'...
            ;'pAuthor'     [], 'ischar' ...
            ;'description' [], 'ischar' ...
             ...
            ;'nBlkPerLvl',       [],'isint' ...
            ;'rndSd',      [],'isint' ...
            ;'stdStruct',  [],'isstruct' ...
            ... %one of these
            ;'nIntrvlPerTrl',    [],'isint' ...
            ;'nCmpPerTrl',    [],'isint' ...
            ... %one of these
            ;'nTrl',       [],'isint' ...
            ;'nTrlPerBlk', [],'isint' ...
            ;'nTrlPerLvl', [],'isint' ...
          };
    end
end
end
