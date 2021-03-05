classdef imapVet < handle & LR & imapCommon & imapVet_main & imapVet_plot & imapVet_ind_plot & imapVet_util
properties
%INPUT
    %database
    % From mapIndGen
    %imgType     % type
    %imgName
    % VETOPTS

    % OPTS
    order   %optional

% OUTPUT
    vet
% OTHER
    INDS  % Cell
end
properties(Hidden = true)
    % CP STUFF
    %IszRC       % specified in stead of type
    xyz
    db

    saveDir

    % ITERATION
    %LorR
    k % lorr
    I % image number

    bap

    bCP

    blankmap

    % STATIC LOOKUP
    %LandR
    %nImg
    nImap
    %nLandR

    TYPE='vet';
end

methods

%% CONSTRUCTOR
    function obj = imapVet(database,Opts,plotOpts,bRun)
        obj.database=database;
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
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
        [obj,vetOpts]=obj.parse_Opts(Opts);
        obj.get_img_db_info();
        obj.init_imapVets_from_vetOpts(vetOpts);
        obj.get_hash();
        obj.parse_plotOpts(plotOpts);
        obj.save_def();
        if bRun
            obj.main();
        end
    end
% PARSE
    function [obj,vetOpts]=parse_Opts(obj,Opts)
        P=imapVet.get_parse();
        [Opts,vetOpts]=structSplit(Opts,P(:,1));
        obj=parse(obj,Opts,P);
        obj.parse_LorRorB();

    end
    function obj=parse_plotOpts(obj,plotOpts)

        obj.parse_plotOpts_p(plotOpts);

        obj.plotOpts.bPlot=obj.plotOpts.bPostImage ||...
                           obj.plotOpts.bPreEdge || ...
                           obj.plotOpts.bPostEdge || ...
                           obj.plotOpts.bPreAt || ...
                           obj.plotOpts.bPostAt || ...
                           obj.plotOpts.bPreIn || ...
                           obj.plotOpts.bPostIn;
        obj.plot_vet_init();
    end

%% GET

%% INIT IMAPS
    function obj=init_imapVets_from_vetOpts(obj,vetOpts)
        ImapNames=fieldnames(vetOpts);
        n=length(ImapNames);
        [X,Y] = meshgrid(1:obj.IszRC(2), 1:obj.IszRC(1));
        for i = 1:n
            name=ImapNames{i};
            vetOpt=vetOpts.(name);
            obj.INDS{i}=imapVet_ind(obj.LorRorB,[],name,obj.database,vetOpt,1,X,Y);
        end
        obj.combine_similar_imaps(ImapNames);
        obj.nImap=numel(obj.INDS);
        obj.bCP=0;
        for i = 1:obj.nImap
            obj.bCP=obj.bCP | obj.INDS{i}.bVetCP;
        end
    end
    function obj=combine_similar_imaps(obj,ImapNames)
        if numel(obj.INDS) == 0
            return
        elseif numel(obj.INDS) == 1
            obj.INDS{1}.vetImgType=ImapNames{1};
            return
        end
        indUnq=structUniqueInd(obj.INDS{:});
        N=max(indUnq);
        Imaps=cell(N,1);
        vetNames=cell(N,1);
        for i = 1:N
            inds=find(indUnq==i);
            ind=inds(1);
            Imaps(i)=obj.INDS(ind);
            vetNames{i}=ImapNames(inds);
            Imaps{i}.vetImgType=ImapNames(inds);
        end
        obj.INDS=Imaps;
    end
% INIT
    function obj=init_vet(obj)
        c={~obj.blankmap ~obj.blankmap};
        obj.vet=c;
        for i = 1:obj.nImap
            obj.INDS{i}.vet=c;
        end
    end
    function obj=init_gd_all(obj)
        % reset for new image
        c={~obj.blankmap ~obj.blankmap};
        for i = 1:obj.nImap
            obj.INDS{i}.gdMap=cell(1,2);
            for k = 1:2
                obj.INDS{i}.gdMap{k}=c;
            end
        end
    end
    function obj=init_gd_LandR(obj,i)
        % reset for non cumu
        for k = 1:2
            obj.init_gd(i,k);
        end
    end
    function obj=init_gd(obj,i,k)
        % reset on each iteration
        c={~obj.blankmap ~obj.blankmap};
        obj.INDS{i}.gdMap{k}=c;
    end
    function obj=vet_maps_order_first(obj)
        % order, imap, LR
        for o = 1:length(obj.order)
            fld=obj.order{o};
            for i = 1:obj.nImap
                for kk  = 1:obj.nLandR
                    obj.k=kk;
                    obj.LorR=obj.LandR{kk};
                    obj.vet_helper(fld,kk,i,0);
                end
            end
        end
    end
%% VET
    function obj=vet_maps_LR_first(obj)
        % LR, order, imap
        for kk  = 1:obj.nLandR % LOOP OVER ANCHOR EYE
            obj.k=kk;
            obj.LorR=obj.LandR{kk};
            for o = 1:length(obj.order)
                fld=obj.order{o};
                for i = 1:obj.nImap
                    obj.vet_helper(fld,kk,i,1);
                end
            end
        end
    end
    function obj=vet_helper(obj,fld,kk,i,LRfirst)
        if strcmp(fld,'edge') % XXX
            return
        end
        obj.plotOpts.verboselvl=2; % NOTE

        fldStr=fld;
        fldStr(1)=makeUpperCase(fldStr(1));

        bVet=any(obj.INDS{i}.(['bVet' fldStr])(kk,:));
        bVetLRfirst=obj.INDS{i}.(['bVet' fldStr 'LRfirst'])(kk);
        bVetCumu=obj.INDS{i}.(['bVet' fldStr 'Cumu'])(kk);

        if ~bVet || xor(LRfirst,bVetLRfirst)
            return
        end

        if bVetCumu
            % CUMULATIVE gd inds across loops
            obj.copy_vet_2_gd(kk,i);
        else
            % RESET gd inds every loop
            obj.init_gd(i,kk);
        end

        bEndO=~bVetLRfirst && (obj.LorRorB~='B' || (obj.LorRorB=='B' && kk==2));
        bEndLR=bVetLRfirst && strcmp(fld,obj.order{end});
        bEnd = bEndLR || bEndO;

        % PLOT
        bPlot=obj.plotOpts.bPlotI && obj.plotOpts.verboselvl>1;

        % VET
        obj.INDS{i}.(['vet_' fld])(kk, bPlot, obj.prog);

        % UPDATE VET
        if bEndLR
            obj.comb_vet_ind_LR(kk);
        elseif bEndO
            obj.comb_vet_ind_imap(i);
        end
        obj.update_vet(i);

        % FINALIZE PLOT
        if bPlot && bEnd
            obj.debug_plot_end(kk,i);
        elseif obj.plotOpts.bPlotI && bEnd
            obj.plot_end(kk,i,fldStr,obj.I);
        end

    end
    function obj=copy_vet_2_gd(obj,kk,i)
        obj.INDS{i}.gdMap{1}{1}=obj.vet{1};
        obj.INDS{i}.gdMap{2}{1}=obj.vet{1};
        obj.INDS{i}.gdMap{2}{2}=obj.vet{2};
        obj.INDS{i}.gdMap{1}{2}=obj.vet{2};
    end
    function obj=comb_vet_ind_imap(obj,i)
        obj.INDS{i}.vet{1}=obj.INDS{i}.gdMap{2}{1} & obj.INDS{i}.gdMap{1}{1};
        obj.INDS{i}.vet{2}=obj.INDS{i}.gdMap{2}{2} & obj.INDS{i}.gdMap{1}{2};
    end
    function obj=comb_vet_ind_LR(obj,kk)
        for i = 1:length(obj.INDS)
            obj.INDS{i}.vet{kk}=obj.INDS{i}.gdMap{2}{kk} & obj.INDS{i}.gdMap{1}{kk};
        end
    end
    function obj=set_vet(obj,i)
        obj.vet{1}=obj.INDS{i}.vet{1};
        obj.vet{2}=obj.INDS{i}.vet{2};
    end
    function obj=update_vet(obj,i)
        obj.vet{1}=obj.vet{1} & obj.INDS{i}.vet{1};
        obj.vet{2}=obj.vet{2} & obj.INDS{i}.vet{2};
    end
    function obj=vet_plot_end(obj,k,i,titl,imgNum)
        switch titl
        case 'Edge'
            fignum=32;
        case 'At'
            fignum=33;
        case 'In'
            fignum=34;
        otherwise
            figunum=nFn;
        end

        figure(fignum)

        if ~exist('titl','var') || isempty(titl)
            titl='';
        end
        nB=obj.LorRorB~='B';
        if k==1 || nB
            clf;
            sgtitle(['vet rolling' newline titl ' Im ' num2str(imgNum) ]);
        end
        l=1:(~nB+1);
        for k = l
            bflag=0;
            subPlot([1,2],1,k)
            imagesc(obj.vet{k});
            formatImage();
            formatFigure('','')
        end
        if k==2 || nB
            drawnow
        end
    end
end
methods(Static=true)
    function P=get_parse()
        P=   { 'LorRorB','B','isLorRorB'...
              ;'imgNums',[],'isallintorempty'...
              ;'order',{'edge','at','in'},'iscell'... % TODO
        };
    end
    function P=get_parse_plot()
        P= { ...
                'verboselvl',1,@isint...
               ;'bPostImage',0,@isbinary...
               ;'bPreEdge',0,@isbinary...
               ;'bPostEdge',0,@isbinary...
               ;'bPreAt',0,@isbinary...
               ;'bPostAt',0,@isbinary...
               ;'bPreIn',0,@isbinary...
               ;'bPostIn',0,@isbinary...
        };
    end
end
end
