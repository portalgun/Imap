classdef imapVet_plot < handle
methods
    function obj=plot_vet(obj,i,fld,kk,startORend)
        if ~isfield(obj.plotOpts,'vetFig') || isempty(obj.plotOpts.vetFig)
            obj.plotOpts.vetFig=nFn;
        end
        figure(obj.plotOpts.vetFig);

        imgflag=0;
        if ~isfield(obj.plotOpts,'vetimgnum') || isempty(obj.plotOpts.vetimgnum) || obj.plotOpts.vetimgnum ~= obj.I
            obj.plotOpts.vetsgtitl=[];
            clf();
            figure(obj.plotOpts.vetFig);
            imgflag=1;
        end
        obj.plotOpts.vetimgnum=obj.I;

        % MOVE
        r=obj.get_row(fld,startORend)+1;
        c=obj.get_col(kk,0)+1;
        nR=obj.plotOpts.nR+1;
        nC=obj.plotOpts.nC+1;

        if isempty(r)
            return
        end

        % TITLES
        if kk==1
            nk=2;
        elseif kk==2
            nk=1;
        end
        LandR={'L','R'};
        LorR=LandR{kk};
        nLorR=LandR{nk};
        if r==1
            titl=LorR;
        else
            titl='';
        end
        if r==1
            ntitl=nLorR;
        else
            ntitl=[];
        end
        if c==1
            rtitl=fld;
        else
            rtitl=[];
        end
        suptitl=['Image ' num2str(obj.I)];

        % Image
        if imgflag
            88
            subPlot([nR,nC],1,kk); hold off
            imagesc(obj.plotOpts.pht{kk}); hold on;
            dk
            formatImage;
            formatFigure;
            if bCP
                subPlot([nR,nC],1,nk); hold off
                imagesc(obj.plotOpts.pht{nk}); hold on;
                formatImage;
                formatFigure();
            end
        end

        % ANCHOR
        %R=obj.INDS{i}.gdRC{kk}{kk}(:,1);
        %C=obj.INDS{i}.gdRC{kk}{kk}(:,2);
        %plot(C,R,'.');

        subPlot([nR,nC],r,c); hold off
        imagesc(obj.INDS{i}.gdMap{kk}{kk})
        formatImage;
        formatFigure('',rtitl,titl);

        % CP
        if obj.bCP
            c=obj.get_col(kk,1);
            subPlot([nR,nC],r,c); hold off

            if c==1
                rtitl=fld;
            else
                rtitl=[];
            end

            imagesc(obj.INDS{i}.gdMap{kk}{nk});
            %R=obj.INDS{i}.gdRC{kk}{nk}(:,1);
            %C=obj.INDS{i}.gdRC{kk}{nk}(:,2);
            %plot(C,R,'.');
            formatImage;
            formatFigure('',rtitl,ntitl);
        end
        if ~isfield(obj.plotOpts,'vetsgtitl') || isempty(obj.plotOpts.vetsgtitl)
            obj.plotOpts.vetsgtitl=sgtitle(suptitl);
        else
            obj.plotOpts.vetsgtitl=suptitl;
        end

        drawnow
    end
    function r=get_row(obj,fld,startORend)
        startInd=strcmp(startORend,'end')+1;
        str={'Pre','Post'};
        fld(1)=makeUpperCase(fld(1));
        str=[str{startInd} fld];
        r=find(ismember(obj.plotOpts.list,str));
    end
    function c=get_col(obj,kk,bCP)
        if kk == 1 && bCP
            c=2;
        elseif kk == 1
            c=1;
        elseif kk == 2 && bCP
            c=4;
        elseif kk == 2
            c=3;
        end
    end
    function obj=plot_vet_init(obj)
        obj.plotOpts.nR=obj.plotOpts.bPostImage + ...
                        obj.plotOpts.bPreEdge + ...
                        obj.plotOpts.bPostEdge + ...
                        obj.plotOpts.bPreAt + ...
                        obj.plotOpts.bPostAt + ...
                        obj.plotOpts.bPreIn + ...
                        obj.plotOpts.bPostIn;

        if obj.LorRorB=='B'
            obj.plotOpts.nC=2;
        else
            obj.plotOpts.nC=1;
        end
        if obj.bCP
            obj.plotOpts.nC=obj.plotOpts.nC*2;
        end

        list={};
        c=0;
        for i= 1:length(obj.order)
            c=c+1;
            switch obj.order{i}
            case 'in'
                if obj.plotOpts.bPreIn
                    list=[list 'PreIn'];
                end
                if obj.plotOpts.bPostIn
                    list=[list 'PostIn'];
                end
            case 'at'
                if obj.plotOpts.bPreIn
                    list=[list 'PreAt'];
                end
                if obj.plotOpts.bPostIn
                    list=[list 'PostAt'];
                end
            case 'edge'
                if obj.plotOpts.bPreEdge
                    list=[list 'PreEdge'];
                end
                if obj.plotOpts.bPostEdge
                    list=[list 'PostEdge'];
                end
            end
        end
        if obj.plotOpts.bPostImage
            list=[list 'PostVet'];
        end
        obj.plotOpts.list=list;

    end
end
end
