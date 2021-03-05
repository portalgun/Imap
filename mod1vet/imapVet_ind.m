classdef imapVet_ind < handle & imapCommon & LR & idxConversions & imapVet_ind_at & imapVet_ind_edge & imapVet_ind_in & imapVet_ind_plot
% TODO PLOT OPTS?
% FOR SELF CHECKS, LOAD BMAP AND VETMAP FROM SAME PLACE
% need to vet PszXY according to max disparity speed etc.
properties
    % INPUT
    vetImgType

    % OPTS
    minDensity %is dense enougght
    %
    minZoneSep %zone not neighboring too close to zone by distance
    %
    minZoneSepHori %zonenot neighboring too close to zone norizonally
    %
    minZoneSepVert %zone not neighboring too close to zone vertically
    %
    minCntrSep %values not neighboring too close to center pixel
    %
    minZoneCntrSep %zone not neighboring too close to center pixel
    %
    bVetBranch %no branching
    %
    bVetSigCntr % center is sig
    %
    ctrORedgeORnon  %edge
    ctredgFORorEITHERorAGAINST
    %
    nSigThresh % not toomany significant regions
    %
    widthCount     % is wide enough
    widthCountBuffer
    bWidthTwoWay
    widthBuffer
    minMaxPixWidth
    %
    heightCount  % is tall enough
    heightCountBuffer
    bHeightTwoWay
    heightBuffer
    minMaxPixHeight
    %
    PszXY
    PszRC
    nPixSigThresh

    bVetCP

    % flags
    bVetEdgeLRfirst
    bVetAtLRfirst
    bVetInLRfirst

    bVetEdgeCumu
    bVetAtCumu
    bVetInCumu

    bVetEdge
    bVetAt
        bVetAgainst
        bVetFor
        bVetEither
    bVetIn
        bVetInVec
        bVetObj
           bVetWidth
           bVetHeight
           %bVetSigCtr
           bVetCntrNeighb
           bVetCntrNeighbZone
           bVetNeighbZoneVert
           bVetNeighbZoneHori
           bVetNeighbZone
           %bVetBranch
        bVetWn
           bVetDensity
           bVetMaxNumSig
end
properties(Hidden=true)
    p % Prog
    bp

    xyz

    CPs
    gdMap  % main
        gdRC
        gdInd
    tstMap  % test
    vet  % complete


    continueFlag
    returnFlag
    bStart

end
methods
    function obj=imapVet_ind(LorRorB,imgType,vetImgType,database,Opts,bNested,X,Y)
        obj.X=X;
        obj.Y=Y;
        obj.LorRorB=LorRorB;
        if isempty(imgType)
            %obj.imgType='img';
        elseif exist('imgType','var') && ~isempty(imgType)
            %obj.imgType=imgType;
        end
        if ~exist('bNested','var') || isempty(bNested)
            bNested=0;
        end
        if exist('vetImgType','var') && ~isempty(vetImgType)
            obj.vetImgType=vetImgType;
        end
        if exist('database','var')
            obj.database=database;
        end
        obj.get_img_db_info();
        obj.parse_Opts(Opts);

        if bNested
            obj.vetImgType=[];
        else
            main();
        end
    end
    function obj=parse_Opts(obj,Opts)
        if isfield(Opts,'PszXY') && size(Opts.PszXY,1)==1 && size(Opts.PszXY,2)==2
            Opts.PszXY=[Opts.PszXY; Opts.PszXY];
        end
        if isfield(Opts,'PszRC') && size(Opts.PszRC,1)==1 && size(Opts.PszRC,2)==2
            Opts.PszXY=[Opts.PszRC; Opts.PszRC];
        end
        if isfield(Opts,'PszXY') && (~isfield(Opts,'PszRC') || isempty(Opts.PszRC))
            Opts.PszRC=fliplr(Opts.PszXY);
        elseif isfield(Opts,'PszRC') && (~isfield(Opts,'PszXY') || isempty(Opts.PszXY))
            Opts.PszXY=fliplr(Opts.PszRC);
        end

        FLDS={...
             'nPixSigThresh',                   30,'bVetObj'...
            ;'PszXY',                       [-1 -1],'bVetWn'...
            ;'PszRC',                       [-1 -1],'bVetWn'...
            ...
            ;'ctrORedgeORnon',              'non','bVetEdge'...
            ;'ctredgFORorEITHERorAGAINST',  'FOR','bVetEdge'...
            ...
            ;'minMaxPixWidth',                [18, inf],'bVetWidth'...
            ;'widthBuffer',                 5,'bVetWidth'...
            ;'bWidthTwoWay',                     0,'bVetWidth',...
            ;'widthCount', -1 ,'bVetWidth'....
            ;'widthCountBuffer',0,'bVetWidth'....
            ...
            ;'minMaxPixHeight',                [18, inf],'bVetHeight'...
            ;'heightBuffer',                5,'bVetHeight'... %XXX
            ;'bHeightTwoWay',                     0,'bVetHeight',...
            ;'heightCount', -1 ,'bVetHeight'....
            ;'heightCountBuffer',0,'bVetHeight'....
            ...
            ;'nSigThresh',                  1,'bVetMaxNumSig'...
            ...
            ;'minZoneSep',                  10,'bVetNeighbZone' ...
            ;'minZoneSepHori',              10,'bVetNeighbZoneHori'...
            ;'minZoneSepVert',              10,'bVetNeighbZoneVert'...
            ;'minZoneCntrSep',              10,'bVetCntrNeighbZone'...
            ;'minCntrSep',                  10,'bVetCntrNeighb'...
            ...
            ;'minDensity',                  0,'bVetDensity'...
            ;'bVetBranch',                  0,'bVetBranch'...
            ;'bVetSigCntr',                 0,'bVetSigCntr'...
            ;'bVetAgainst',                 0,'bVetAgainst'...
            ;'bVetFor',                     0,'bVetFor'...
            ;'bVetEither',                  0,'bVetEither'...
            ...
            ;'bVetAtCumu',                  [0;0], 'bVetAt'...
            ;'bVetEdgeCumu',                0, 'bVetEdge'...
            ;'bVetInCumu',                  [0;0], 'bVetIn'...
            ...
            ;'bVetAtLRfirst',               [0;0], 'bVetAt'...
            ;'bVetEdgeLRfirst',             0, 'bVetEdge'...
            ;'bVetInLRfirst',               [0;0], 'bVetIn'...
            ...
            %;'InCombLvl',                     1, 'bVetIn'...
            %;'EdgeCombLvl',                     1, 'bVetEdge'...
            %;'AtCombLvl',                     1, 'bVetAt'...


};
        p=inputParser();
        for i = 1:size(FLDS,1)
            p.addParameter(FLDS{i,1},FLDS{i,2});
        end

        p=parseStruct(Opts,p);
        flds=fieldnames(p.Results);
        for i = 1:length(flds)
            fld=flds{i};
            obj.(fld)=p.Results.(fld);
        end

        obj=parse2(obj,FLDS);

        if obj.heightCount(1)==-1
            obj.heightCount(1)=obj.PszXY(1,2);
        end
        if obj.heightCount(2)==-1
            obj.heightCount(2)=obj.PszXY(2,2);
        end
        if obj.widthCount(1)==-1
            obj.widthCount(1)=obj.PszXY(1,1);
        end
        if obj.widthCount(2)==-1
            obj.widthCount(2)=obj.PszXY(2,1);
        end


        % NOTE is this a good idea?
        if mod(obj.PszXY(1,2),2)==0 || mod(obj.PszXY(2,2),2)==0
            disp('PszXY must be odd! Changing...');
        end
        if mod(obj.PszXY(1,2),2)==0
            obj.PszXY(1,2)=obj.PszXY(1,2)+1;
        end
        if mod(obj.PszXY(2,2),2)==0
            obj.PszXY(2,2)=obj.PszXY(2,2)+1;
        end

        obj.PszRC=fliplr(obj.PszXY);
        if size(obj.PszRC,1)==1
            obj.PszRC=[obj.PszRC; obj.PszRC];
            obj.PszXY=[obj.PszXY; obj.PszXY];
        end
        if all(~isnan(obj.PszRC(1,:)))
            obj.blankPatch{1}=false(obj.PszRC(1,:)); % XXX
        elseif ~all(isnan(obj.PszRC(1,:)))
            error('Inalid PszRC 1')
        end
        if all(~isnan(obj.PszRC(2,:)))
            obj.blankPatch{2}=false(obj.PszRC(2,:));
        elseif ~all(isnan(obj.PszRC(2,:)))
            error('Inalid PszRC 2')
        end

        %HEIGHT (1) AND WIDTH (2) OF REGION TO CHECK FOR Map
        obj.MapkernRadHW    = fliplr(floor(obj.PszXY./2));
        %DENSITY ONLY
        obj.MapkernArea     = (obj.MapkernRadHW(:,1).*2+1).*(obj.MapkernRadHW(:,2).*2+1);

        obj.bVetAt= obj.bVetFor | obj.bVetEither | obj.bVetAgainst;

        obj.bVetObj=obj.bVetWidth | obj.bVetHeight | obj.bVetMaxNumSig | obj.bVetSigCntr | obj.bVetCntrNeighbZone | obj.bVetNeighbZone | obj.bVetNeighbZoneHori | obj.bVetNeighbZoneVert | obj.bVetBranch;
        obj.bVetWn = obj.bVetObj | obj.bVetDensity;

        obj.bVetInVec=obj.bVetCntrNeighb; %& transpose(all(isnan(obj.PszRC),2));
        obj.bVetIn=obj.bVetWn | obj.bVetInVec;

        obj.bVetCP = any(obj.bVetAt(:,2) | obj.bVetIn(:,2) | obj.bVetEdge(:,2));


        % PARSE 4
        names=fieldnames(obj);

        nflds={'bVetCP','bVetAtLRfirst','bVetEdgeLRfirst','bVetInLRfirst','bVetAtCumu','bVetEdgeCumu','bVetInCumu'};
        for i = 1:length(names)
            name=names{i};
            if ~startsWith(name,'b') || ismember(name,nflds)
                continue
            end
            if obj.LorRorB=='B' && (size(obj.(name),2)==2 && size(obj.(name),1)==1)
                obj.(name)=[obj.(name); obj.(name)];
            elseif obj.LorRorB=='L' && (size(obj.(name),2)==2 && size(obj.(name),1)==1)
                obj.(name)=[obj.(name); 0, 0];
            elseif obj.LorRorB=='R' && (size(obj.(name),2)==2 && size(obj.(name),1)==1)
                obj.(name)=[0,0; obj.(name)];
            end
        end

        flds={'LRfirst','Cumu'};
        orders={'Edge','At','In'};

        for i = 1:length(flds)
            fld=flds{i};
            for j = 1:length(orders)
                order=orders{j};
                obj.double_helper(fld,order);
            end
        end

    end
    function obj=double_helper(obj,fld,order)
        name=['bVet' order fld];
        oname=['bVet' order];

        if numel(name)==2 && size(obj.(name),1)==1
            obj.(name)=transpose(obj.(name));
        end

        if all(isnan(obj.(name)))
            obj.(name)=~obj.(oname)(:,1);
        end
    end
    function obj=mod_init(obj)
        obj.returnFlag=0;
        obj.continueFlag=0;
    end
    function obj=get_tstMap(obj,I,kk)
        %I - im num
        %k - lorr
        LandR={'L','R'};
        k=LandR{kk};
        for i = 1:length(obj.vetImgType)
            hash=obj.vetImgType{i};
            out=getImg(obj.database,'img',hash,I,k);
            if ~exist('OUT','var')
                obj.tstMap{kk}=out;
            else
                obj.tstMap{kk}=obj.tstMap{kk} & out;
                % XXX? vetatoragainst
            end

        end

    end
%% CONVERSTIONS
    function obj=update_from_map(obj,anch,cp)
        [obj.gdInd{anch}{cp},obj.gdRC{anch}{cp}]=obj.get_from_map(obj.gdMap{anch}{cp});
    end
    function obj=update_anch_from_map(obj,anch)
        [k,~]=obj.xyz.get_k(anch);
        [obj.gdInd{k}{k},obj.gdRC{k}{k}]=obj.get_from_map(obj.gdMap{k}{k});
    end
    function obj=update_CP_from_map(obj,anch)
        [k,nk]=obj.xyz.get_k(anch);
        [obj.gdInd{k}{nk},obj.gdRC{k}{nk}]=obj.get_from_map(obj.gdMap{k}{nk});
    end
    function obj=update_vet_from_map(obj,anch)
        [k,~]=obj.xyz.get_k(anch);
        obj.vet{k}=obj.gdMap{k}{k};
    end
    function obj=update_CP_from_anch(obj,anch)
        [k,nk]=obj.xyz.get_k(anch);
        obj.update_anch_from_map(anch);

        Anch=obj.xyz.CPs{k}{k};
        cps=round(obj.xyz.CPs{k}{nk});

        gdCP=cps(ismember(Anch, obj.gdRC{k}{k},'rows') & all(~isnan(Anch),2) ,:);

        ind=any(gdCP <= 0 | gdCP > obj.IszRC | isnan(gdCP),2);
        gdCP(ind,:)=[];

        gdCPmap=obj.get_map_from_RC(gdCP);

        obj.gdMap{k}{nk}=obj.gdMap{k}{nk} & gdCPmap;
        obj.update_CP_from_map(anch);

    end
    function obj=update_anch_from_CP(obj,anch)
        [k,nk]=obj.xyz.get_k(anch);
        obj.update_CP_from_map(anch);

        Anch=obj.xyz.CPs{k}{k};
        cps=round(obj.xyz.CPs{k}{nk});

        gdAnch=Anch(ismember(cps, obj.gdRC{k}{nk},'rows') & all(~isnan(cps),2),:);

        ind=any(gdAnch <= 0 | gdAnch > obj.IszRC | isnan(gdAnch),2);
        gdAnch(ind,:)=[];

        gdAnchmap=obj.get_map_from_RC(gdAnch);

        obj.gdMap{k}{k}=obj.gdMap{k}{k} & gdAnchmap;
        obj.update_anch_from_map(anch);
    end
    function obj=update_vet_from_CP(obj,anch)
        [k,nk]=obj.xyz.get_k(anch);
        obj.update_CP_from_map(anch);

        Anch=obj.xyz.CPs{k}{k};
        cps=round(obj.xyz.CPs{k}{nk});

        gdAnch=Anch(ismember(cps, obj.gdRC{k}{nk},'rows') & all(~isnan(cps),2),:);

        ind=any(gdAnch <= 0 | gdAnch > obj.IszRC | isnan(gdAnch),2);
        gdAnch(ind,:)=[];

        gdAnchmap=obj.get_map_from_RC(gdAnch);

        obj.vet{k}=obj.gdMap{k}{k} & gdAnchmap;
    end
%% PLOT
    function obj=plot_center_or_edge(obj,num)
        obj.figCtrOrEdg=figure(num);
        hold on

        imagesc(obj.tstMap{ind}.^.5); axis image; colormap gray; hold on
        set(gca,'xtick',[]); set(gca,'ytick',[]);
        scatter(obj.gdRC(:,2),obj.gdRC(:,1),'r.');
    end
    function obj=message(obj,msg,anch,cp)
        LR='LR';
        if exist('anch','var') && ~isempty(anch)
            msg=[msg ' ' LR(anch)];
        end
        if exist('cp','var') && ~isempty(cp)
            msg=[msg ' ' LR(cp)];
        end
        if obj.bp
            obj.p.set_msg(msg);
        end
    end
end
end
