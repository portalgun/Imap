classdef imapSmp_main < handle
methods
    function obj=run(obj)
        obj.main();
    end
end
methods(Access=protected)
    function obj=main(obj)
        obj.p=pr(obj.nImg,1,'Sampling');
        if obj.bSaveAsAll && exist([obj.get_fname_all '.mat'],'file')
            obj.p.c();
            return
        elseif obj.bSampleDouble
            obj.main_double();
        else
            obj.main_single();
        end
        obj.p.c();
    end
    function obj=main_single(obj)
        % TODO
    end
    function obj=sample_single(obj)
        % TODO
    end
    function obj=main_double(obj)
        obj.check_all_fnames();
        obj.init();
        obj.get_bin_hist_all();
        if obj.counts_exists();
            obj.load_counts();
        end
        if obj.all_exists();
            obj.load_smp_all();
        end

        bRan=0;
        for ii = 1:obj.nImg
            obj.I=obj.imgNums(ii);
            %obj.I=8; % XXX

            % XXX
            if all(obj.imExists(ii,2))
                obj.p.u(1);
                continue
            end
            obj.p.u();

            obj.get_range_data();
            obj.SAMPLER.set_cpLookup(obj.xyz.cpLookup);

            obj.get_bin_img();
            obj.get_bin_hist_img();

            if obj.plotOpts.bProg
                obj.get_pht();
            end
            obj.reset_viewed_bins();
            for bb = 1:obj.nBin
                obj.get_next_bin(bb);
                obj.get_bap();
                obj.get_pre();
                obj.get_PctrInd_from_bap();
                if isempty(obj.PctrInd)
                    continue
                end
                obj.sample_double();
            end
            %dk % XXX
            obj.save_counts();
            obj.save_smp_all();
            obj.plot_prog();
            obj.save();
            bRan=1;
        end
        if bRan
            obj.plot_count_dist_p();
        end
    end
    function obj=reset_viewed_bins(obj)
        obj.viewedBins=false(obj.nBin,1);
        obj.SAMPLER.reset_seed();
        obj.SAMPLER.reset_lookup();
    end
    function obj=get_bap(obj)
        obj.bap{1}=obj.bin{1}==obj.binNums(obj.B);
        obj.bap{2}=obj.bin{2}==obj.binNums(obj.B);
    end
    function obj=get_PctrInd_from_bap(obj)
        obj.PctrInd=obj.get_ind_from_map_bi(obj.bap);
    end
    function obj=get_pre(obj)
        if ~isempty(obj.PctrIndPri)
            obj.Pre=obj.PctrIndPri(obj.B,obj.I,:);
        end
    end
    function obj=get_next_bin(obj,bb)
        inds=1:obj.nBin;

        cumBinHistCum=sum(obj.countsBIL,[2,3]);

        % ORDER OF PRIORITY
        switch obj.priority
        case 'cumu'
            bins=[obj.viewedBins, cumBinHistCum,  obj.binHistAll];
        case 'all'
            bin=[obj.viewedBins, obj.binHistAll];
        case 'img'
            bins=[obj.viewedBins, obj.binHistImg];
        end


        [binsrt,ind]=sortrows(bins);
        % unviewed (zeros,leftmose) appear at top
        obj.B=ind(1);
        obj.viewedBins(ind(1))=1;

    end
    function obj=sample_double(obj)
        % DAVE MAX SAMPLING METHOD

        K=get_LorR_first(obj);


        if obj.bBinOverlap
            obj.SAMPLER.reset_lookup();
        end
        obj.SAMPLER.reset_samples();
        obj.SAMPLER.run(obj.PctrInd, obj.Pre, K);

        %COUNTS
        COUNT=obj.SAMPLER.count;
        obj.countsBIL(obj.B,obj.I, :) = COUNT;
        obj.cumLandRcounts            = obj.cumLandRcounts + COUNT;

        % INDS
        INDS=obj.SAMPLER.IctrInd;
        obj.smpInd(obj.B, obj.I, :)   = INDS;

        % RC
        RC=zeros(size(INDS{1},1),2);
        [RC(:,1),RC(:,2)]=arrayfun(@(x) ind2sub(obj.IszRC,x), INDS{1});
        obj.smpRC{obj.B,obj.I,1}=RC;

        RC=zeros(size(INDS{2},1),2);
        [RC(:,1),RC(:,2)]=arrayfun(@(x) ind2sub(obj.IszRC,x), INDS{2});
        obj.smpRC{obj.B,obj.I,2}=RC;

        function K=get_LorR_first(obj)
            if obj.cumLandRcounts(1) > obj.cumLandRcounts(2)
                K=2;
            elseif obj.cumLandRcounts(1) <= obj.cumLandRcounts(2)
                K=1;
            end
        end
    end
    function im=get_bin_hist_img(obj)
        obj.binHistImg=sum(obj.binHist(:,obj.I,:),[3,2]);
    end
    function obj=get_bin_hist_all(obj)
        obj.binHist=obj.get_bin_counts();
        obj.binHist=obj.binHist(obj.binNums,:,:);
        obj.binHistAll=sum(obj.binHist,[2,3]);
    end
end
end
