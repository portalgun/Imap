classdef imapPch_main < handle
methods
    function obj=run(obj)
        obj.main();
    end
end
methods(Access=protected)
    function obj=main(obj)
        %obj.reset_p(); % XXX
        obj.save_genOpts();
        obj.save_db(); % XXX SLOW - why?

        obj.get_smp_all();
        obj.limit();
        obj.get_edges();

        obj.get_name_index();
        obj.get_src_table();

        dire=ptch.get_directory_p(obj.database,obj.hash);
        obj.check_all_fnames(obj.fnames,dire);

        obj.P=0;
        obj.p=pr(length(obj.fnames),1,'Creating patches');
        profile clear
        profile on

        if obj.rndSd~=0
            rng(obj.rndSd);
        end
        obj.badPtchs=[];
        for ii = 1:obj.nImg
            obj.I=obj.imgNums(ii);
            bStartI=1;
            for kk = 1:2
                obj.k=kk;
                bStartK=1;

                for bb= 1:obj.nBin
                    obj.B=bb;
                    obj.select_bin();
                    obj.select_nSmp();


                    for ss = 1:obj.nSmp
                        obj.P=obj.P+1;

                        if obj.imExists(obj.P)
                            obj.badPtchs(end+1,1)=0;
                            obj.p.u(1);
                            continue
                        end
                        obj.p.u();

                        obj.S=obj.select_indInd(ss);
                        obj.select_smpRC(ss);

                        if bStartI
                            obj.get_srcs();
                            bStartI=0;
                        end
                        if bStartK
                            obj.get_gen(); % TODO replace w/ table
                            bStartK=0;
                        end
                        obj.select_gen(); % TODO replace w/ table

                        obj.select_fname();
                        obj.set_srcInfo();

                        obj.get_ptch();
                        if obj.badPtchs(end)==0
                            obj.save();
                        end
                    end
                end
            end
        end
        obj.p.c();
    end
%% SRC
    function obj=get_srcs(obj)
        names={'pht'};
        names=union(names, obj.mapNames);
        names=union(names, obj.mskNames);
        names=union(names, obj.texNames(~ptch.isgentex(obj.texNames)));

        for i = 1:length(names)
            name=names{i};
            if strcmp(name,'xyz')
                continue
            end
            obj.src.(name)=cell(1,2);
            for k = 1:2
                obj.src.(name){k}=obj.get_imap('img',name,k);
            end
        end

        % XYZ
        obj.xyz=XYZ(obj.database,obj.I,obj.db);
        obj.xyz.get_cpLookup_bi();
        obj.src.xyz=obj.xyz.xyz;
        obj.src.CPs=obj.xyz.CPs;
    end
%% SELECT
    function obj=limit(obj)
        smpRC=obj.smpRCall;
        limBinMin=obj.limBinMin;

        counts=cellfun(@(x) size(x,1), smpRC);
        countsBin=sum(counts,[2,3]);
        if limBinMin==0
            return
        elseif obj.limBinMin==-1;
            lim=min(countsBin);
        else
            lim=limBinMin;
        end
        nPrune=countsBin-lim;

        for b = 1:length(countsBin)
            count=countsBin(b);
            if countsBin(b) <= 0
                continue
            end
            nRm=aneal_count_fun(counts(b,:,:),lim);
            smpRC(b,:,:)=prune_fun(nRm,smpRC(b,:,:));
        end

        % CHECK
        counts=cellfun(@(x) size(x,1), smpRC);
        %counts=sum(counts,[2,3]) NOTE
        obj.smpRCall=smpRC;
        function nRm = aneal_count_fun(counts,lim)
            [cc,ind]=sort(counts(:),'descend');
            cco=cc;
            [~,idx_rev]=sort(ind);
            i=0;
            nRm=zeros(size(cc));

            %% GET NUMBER OF SAMPLES TO REMOVE, by pruning off the top of each image bin
            lastcount=sum(cc);
            while true
                i=i+1;
                lastcount=count;
                last=cc;
                cc(1:i)=cc(i);

                count=sum(cc);
                if count == lim
                    break
                elseif count < lim
                    cc=last;
                    count=lastcount;
                    break
                end
            end
            nRm=cco-cc;
            nRm=nRm(idx_rev);
        end
        function smpRC=prune_fun(nRm,smpRC)

            for i = 1:length(nRm)
                n=cellfun(@(x) size(x,1), smpRC(i));
                indsRm=randperm(n,nRm(i));
                if nRm(i)==0
                    continue
                end
                smpRC{i}(indsRm,:)=[];
            end
        end
    end
    function obj=set_srcInfo(obj)
        if obj.k==1; nk=2; else; nk=1 ;end
        obj.srcInfo.I=obj.I;
        obj.srcInfo.K=obj.k;
        obj.srcInfo.B=obj.B;
        obj.srcInfo.S=obj.S;
        obj.srcInfo.P=obj.P;
        obj.srcInfo.PctrRC=cell(1,2);
        obj.srcInfo.PctrRC{obj.k}=obj.smpRC;
        obj.srcInfo.PctrRC{nk}=obj.xyz.lookup_CP(obj.smpRC,obj.k);
        obj.srcInfo.fname=obj.fname;
        obj.srcInfo.get_LorR;
        obj.srcInfo.binVal=obj.binVal;
        obj.srcInfo.Val=obj.val;
    end
    function obj=select_fname(obj)
        obj.fname=obj.fnames{obj.P};
    end
    function obj=select_bin(obj)
        obj.binVal=obj.edges(obj.B);
    end
    function obj=select_nSmp(obj)
        obj.nSmp=min( [obj.maxSmpPerImg, size(obj.smpRCall{obj.B,obj.I,obj.k},1)] );
        if obj.rndSd==0
            obj.smpIndInd=1:obj.nSmp;
        else
            obj.smpIndInd=randperm(obj.nSmp);
        end
    end
    function S=select_indInd(obj,ss)
        S=obj.smpIndInd(ss);
    end
    function obj=select_smpRC(obj,ss)
        try
            obj.smpRC=obj.smpRCall{obj.B,obj.I,obj.k}(obj.S,:);
        catch ME
            disp(size(obj.smpRCall{obj.B,obj.I,obj.k}));
        end
    end
    function obj=select_gen(obj)
        obj.val=obj.gen(obj.smpRC(1),obj.smpRC(2));
    end
%% PTCH
    function obj=get_ptch(obj)
        obj.ptch=ptch(fliplr(obj.PszXY), obj.PszRCbuff, obj.srcInfo, obj.bStereo, obj.mapNames, obj.mskNames, obj.texNames, [], obj.src);
        if obj.ptch.badflag==1
            obj.badPtchs(end+1,1)=1;
        else
            obj.badPtchs(end+1,1)=0;
        end

    end
end
end
