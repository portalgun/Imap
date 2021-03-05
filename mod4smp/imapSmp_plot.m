classdef imapSmp_plot < handle
methods
%% PLOT
    function obj=plot_count_dist_p(obj)
        obj.fig_fun('dist');
        imapSmp.plot_count_dist(obj.countsBIL);
        obj.save_fig('dist','fig',0,4);
        drawnow
    end
    function obj=plot_prog(obj)
        if obj.plotOpts.bProg || obj.plotOpts.bSaveProg
            obj.plot_bap_progress(1);
        end
        if  obj.plotOpts.bSaveProg
            obj.save_fig('prog','fig');
        end
    end
    function plot_bins(obj)
        obj.fig_fun('bins')
        counts=obj.counts;
        if size(counts,1) > 1 && size(counts,2) > 2
            counts=sum(counts,[3,2]);
        end

        imapBin.plot_bins_f(obj.edges,counts, 0);
        obj.save_fig('bins','hist',0,0);
        drawnow
    end
    function obj=plot_bins_LR(obj)
        obj.fig_fun('bins');
        hold off
        imapBin.plot_bins_LR_f(obj.edges,obj.counts,obj.bLogBin);
        imapBin.save_fig(f,obj.database,obj.hash,0,3);
        drawnow
    end
    function obj=plot_bins_img(obj)
        if obj.plotOpts.bProgress && ~isfield(obj.plotOpts.f,'bins_img');
            obj.plotOpts.f_bins_img=nFn;
        elseif obj.plotOpts.bProgress
            f=figure(obj.plotOpts.f_bins_img);
        else
            f=figure('visible','off');
        end
        n=obj.plotOpts.binimgf;
        f=figure(n);

        subPlot([1,2],1,1);
        imapBin.plot_bins_img_f(obj.I,obj.k,obj.edges,obj.counts,obj.bLogBin);
        title([num2str(obj.I)]);

        subPlot([1,2],1,2);
        imapBin.plot_imap(obj.bin);

        imapBin.save_fig(f,obj.database,obj.hash,obj.I,obj.k);
        drawnow
    end
    function plot_bap_progress(obj,bPht)
        obj.fig_fun('prog');
        obj.plot_bap_p(obj.I,bPht);
        drawnow
    end
    function plot_bap_p(obj,I,bPht)
    %
    % bins
        if ~exist('I','var')
            I=obj.I;
        end

        if ~exist('bPht','var')
            bPht=1;
        end

        [smpRCL,smpRCR]=obj.select_smpRC(I,[]);
        if bPht
            subPlot([2,1],1,1);
            obj.plot_pht_p();
            title([num2str(I)]);

            subPlot([2,1],2,1);
            obj.plot_pht_p();
        end

        if ~isa(obj,'imapBin')
            obj.plot_patch_win(smpRCL,smpRCR); hold on
        else
            obj.plot_smpRC_p(smpRCL,smpRCR); hold on
        end
        hold off;
    end
    function plot_patch_win(obj,smpRCL,smpRCR)
        W=obj.PszXY(1);
        H=obj.PszXY(2);

        smpRCRc=obj.xyz.lookup_CP(smpRCR,'R');
        smpRCLc=obj.xyz.lookup_CP(smpRCL,'L');

        smpRCR(:,2)=smpRCR(:,2)+obj.xyz.db.IszRC(2);   % right image
        smpRCLc(:,2)=smpRCLc(:,2)+obj.xyz.db.IszRC(2); % right image

        subPlot([2,1],1,1);
        hold on
        imapSmp_plot.plotRectOnIm(smpRCL, H,W,'g',  'LineWidth',.5)
        imapSmp_plot.plotRectOnIm(smpRCLc,H,W,'g:','LineWidth',.5)
        plot(smpRCL(:,2), smpRCL(:,1), 'r.');
        plot(smpRCLc(:,2),smpRCLc(:,1),'r.');

        subPlot([2,1],2,1);
        hold on
        imapSmp_plot.plotRectOnIm(smpRCR, H,W,'y', 'LineWidth',.5)
        imapSmp_plot.plotRectOnIm(smpRCRc,H,W,'y:','LineWidth',.5)
        plot(smpRCR(:,2), smpRCR(:,1), 'r.');
        plot(smpRCRc(:,2),smpRCRc(:,1),'r.');
    end

    function []=plot_smpRC_p(obj,smpRCL,smpRCR,color1,color2)
        if exist('smpRCL','var') && ~isempty(smpRCL)
            plot(smpRCL(:,2),smpRCL(:,1),'.','color',color1)
        end
        if exist('smpRCR','var') && ~isempty(smpRCR)
            plot(smpRCR(:,2)+obj.IszRC(2),smpRCR(:,1),'.','color',color2)
        end
    end
    function [smpRCL,smpRCR]= select_smpRC(obj,I,B)
        if isempty(I)
            I=obj.I;
        end

        bFlag=~exist('B','var') || isempty(B);


        if isa(obj,'imapBin')
            smpRCL=obj.binRC{B,1};
            smpRCR=obj.binRC{B,2};
            return
        elseif bFlag
            smpRCL=vertcat(obj.smpRC{:,I,1});
            smpRCR=vertcat(obj.smpRC{:,I,2});
            return
        else
            smpRCL=obj.smpRC{B,I,1};
            smpRCR=obj.smpRC{B,I,2};
        end

        if obj.k==1
            smpRCL=obj.get_RC_from_map(obj.(TYPE));
            smpRCR=[];
        elseif obj.k==2
            smpRCL=[];
            smpRCR=obj.get_RC_from_map(obj.(TYPE));
        end
    end
    function [CPsL,CpsR] =select_smpRC_Cps(obj,smpRCL,smpRCR)
        % XXX
        CPs{1}=obj.rangeData.get_CPs('L',obj.smpRCL,obj.IppLRXYm,obj.MLR);
        CPs{2}=obj.rangeData.get_CPs('R',obj.smpRCR,obj.IppLRXYm,obj.MLR);
    end
end
methods(Static=true)
    function []=plotRectOnIm(ImCtrRC,h,w,varargin) %function []=plotRectOnIm(ImCtrRC,h,w)
        [x,y]=rect(ImCtrRC,h,w);
        x(:,5)=x(:,1);
        y(:,5)=y(:,1);
        for i = 1:size(x,1)
            plot(x(i,:),y(i,:),varargin{:})
        end

    end
    function plot_count_dist(counts)
        imapBin.plot_count_dist(counts);
    end
end
end
%% PLOTS
