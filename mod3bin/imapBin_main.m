classdef imapBin_main < handle
methods
    function obj=run(obj)
        obj.main();
    end
end
methods(Access=protected)
    function obj=main(obj)
        obj.blankmap=nan(size(obj.blankmap));
        if obj.bGetEdges
            obj.pre_bin();
        end
        obj.bin_maps();
    end
% GET EDGES
    function obj=pre_bin(obj)

        All=[];
        obj.counts=zeros(obj.nBin,max(obj.imgNums),obj.nLandR);
        obj.edges =zeros(obj.nBin,max(obj.imgNums),obj.nLandR);

        p=pr(obj.nImg,1,'Pre binning');
        for ii = 1:obj.nImg
            obj.I=obj.imgNums(ii);
            p.u();

            for kk=1:obj.nLandR
                obj.k=kk;
                obj.LorR=obj.LandR{kk};
                obj.notLorR=obj.notLandR{kk};

                obj.get_image();
                obj.get_vet();

                All=horzcat(All, transpose(obj.img(obj.vet(:))));
            end
        end
        p.c();

        obj.get_all_bins(All);
        obj.save_edges();
        obj.save_counts();
        obj.bGetEdges=0;
    end
    function obj=get_all_bins(obj,All)
        if isempty(obj.bLogBin)
            [obj.bLog,h]=histo.get_bLog(All,obj.nBin)
            obj.counts=h.counts;
            obj.edges=h.edges;
            return
        end

        [obj.counts,obj.edges]=histo.get(All,obj.nBin,'bLog',obj.bLogBin);
    end
%% BIN
    function obj=bin_maps(obj,bPreBin)
        All=[];

        obj.check_all_fnames();
        msg='Binning';
        p=pr(obj.nImg,1,msg);

        if any(obj.imExists,'all')
            obj.load_counts();
        else
            obj.counts=zeros(obj.nBin+1,max(obj.imgNums),obj.nLandR);
        end


        bRan=0;
        for ii = 1:obj.nImg
            obj.I=obj.imgNums(ii);
            p.u();


            bFirst=1;
            for kk=1:obj.nLandR
                if obj.imExists(ii,kk)
                    continue
                end
                bRan=1;
                if bFirst==1 && obj.plotOpts.bProg
                    obj.get_pht();
                    bFirst=0;
                end

                obj.k=kk;
                obj.LorR=obj.LandR{kk};
                obj.notLorR=obj.notLandR{kk};

                obj.get_image();
                obj.get_vet();

                obj.bin_map();
                obj.save();
                obj.save_counts();

                obj.plot_prog();
            end
        end
        p.c();
        if bRan
            obj.plot_bins();
            obj.plot_bins_LR();
            obj.plot_count_dist_p();
        end

    end
    function obj=bin_map(obj)
        vals=discretize(obj.img(obj.vet(:)),obj.edges);
        obj.bin=obj.blankmap;
        obj.bin(obj.vet)=vals;
        c=histcounts(obj.img(obj.vet),obj.edges);
        obj.counts(:,obj.I,obj.k)=c;
    end
end
end
