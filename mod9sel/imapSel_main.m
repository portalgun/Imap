classdef imapSel_main < handle
methods
    function obj=run(obj)
        obj.main();
    end
end
methods(Access=protected)
    function obj=main(obj);

        % blk table
        [obj.blkTable,obj.blkKey]=imapSel.get_blk_table(obj.modes,obj.nBlkPerLvl,obj.nStd,obj.nTrlPerLvl,obj.nCmpPerLvl,obj.nIntrvlPerTrl,obj.blkSd);

        % match blk w dsp table
        inds=obj.match_rows(obj.blkTable,obj.blkKey, obj.dspTable,obj.dspKey, obj.lvlTable.inds, obj.lvlTable.ValKey);

        % sample
        smp_inds=obj.sample_rows(inds,obj.dspTable,obj.dspKey);

        % final table
        [obj.selTable,obj.selKey]=obj.get_sel_table(smp_inds,obj.blkTable,obj.blkKey,obj.dspTable,obj.dspKey);

        % create 'ptchs'
        obj.iterate();

        % EXP
        if obj.bEobj
            obj.create_E();
        end
    end
    function obj=iterate(obj)
        for m = obj.modes
            M=obj.blkTable(:,1)==m;
            for l = 1:obj.nStd
                L=obj.blkTable(:,2)==l;
                for b = 1:obj.nBlkPerLvl
                    B=obj.blkTable(:,3)==b;
                    ind=M & L & B;
                    sTable=obj.selTable(ind,:);

                    name=imapSel.gen_name(obj.prjInfo,m,std,b);
                    obj.PTCHS=ptchs(name,obj.hashes,sTable,obj.selKey,obj.hashes,obj.lvlTable);
                    obj.PTCHS.init(obj.initLvl);
                    obj.PTCHS.save();
                end
            end
        end
        function name=gen_name(prjInfo,mode,std,blk)
            name=Eobj.get_expData_name(prjInfo.prjCode,...
                                prjInfo.imgDTB,...
                                prjInfo.natORflt,...
                                prjInfo.imgDim,...
                                prjInfo.method,...
                                prjInfo.prjInd, ...
                                mode,std,blk);
        end

    end
    function obj=create_E(obj)
        opts=obj.prjInfo;
        opts.nBlkPerLvl=obj.nBlkPerLvl;
        opts.nTrlPerLvl=obj.nTrlPerLvl;
        opts.nTrlPerBlk=obj.nTrlPerBlk;
        % XXX
        opts.Xname       = obj.Xname       ;
        opts.Xunits      = obj.Xunits      ;
        opts.rndSd       = obj.rndSd       ;
        opts.expHost     = obj.get_expHost() ;
        Eobj.new(opts);
    end
    function display=get_expHost(obj)
        % XXX
    end
end
methods(Static=true)
    function inds=match_rows(blkTable,blkKey, dspTable,dspKey, lvlTable,lvlKey)
        % match dsp with table
        % getting all potential patches for a given situatioN
        % bins
        % lvls

        inds=cell(size(blkTable,1),1);
        lvlInd=ismember(blkKey,'lvlInd');
        for i = 1:size(blkTable,1)
            lvlind=blkTable(i,lvlInd);
            lvls=get_lvl_vals(lvlind,lvlTable);
            inds{i}=match_lvls(lvls,lvlKey, dspTable,dspKey);
        end
    end
    function vals=get_lvl_vals(lvlind,lvlTable)
        vals=lvlTable(lvlind,:);
    end
    function match_lvls(lvls,lvlKey, dspTable,dspKey)
        k=zeros(length(lvlsKey),1);
        for i = 1:length(lvlKey)
            k(i)=find(ismember(dspKey,lvlKey{i}));
        end
        dspTable2=cellfun(@convert_fun,dspTable(:,k),UO,false);
        lvls2=cellfun(@convert_fun,lvls,UO,false);

        match=cell(size(lvls2,1));
        for i = 1:size(lvlKey,1)
            match{i}=ismember(dspTable2,lvls2(i,:),'rows');
        end

        function out=convert_fun(in)
            if isnumeric(in)
                out=num2str(in);
            elseif iscell(in)
                out=cellfun(@convertfun,in,UO,false);
            else
                out=in;
            end
        end
    end
    function smp_inds=sample_rows(inds,dspTable,dspKey)
        % uniform landr
        % uniform image rep

        I=vertcat(dspTable{:,(ismember(dspKey,'I'))});
        K=vertcat(dspTable{:,(ismember(dspKey,'k'))});
        %S=vertcat(dspTable{:,(ismember(dspKey,'S'))});

        I_counts=hist(I,unique(I));
        %K_counts=hist(K,unique(K));
        %B_counts=hist(B,unique(B));
        %S_counts=hist(S,unique(S));

        % k counts given image
        k_counts=zeros([size(uniuqe(I),1),2]);
        for i = transpose(unique(I))
            k=K(I==i);
            k_counts(i,:)=hist(k,unique(K));
        end

        % total number of potential patches for each slot
        %pot_counts=cellfun(@numel,inds);

        % ptch_counts - number of times a patch occurs as a candidate
        pot=vertcat(inds{:});
        ptchs=unique(pot);
        ptch_counts=transpose(hist(pot,ptchs));

        % weight values, numbered by images
        %   I, K, pot_counts,
        weights_I=I_counts ./ sum(I_counts);
        %weights_K=k_counts ./ sum(k_counts,2);

        % weight values, number by patch
        weights_p=ptch_counts ./ sum(ptch_counts);

        % weight value, numbered by inds
        %weights_inds_counts=potCounts ./ sum(potCounts);

        % make tables like inds, but I counts etc. weights
        inds_w=inds;
        for i = 1:length(ptch_counts)
            ptch_num=ptchs(i);
            inds_w_ptch=cellfun(@(x) ismember(x,ptch_num),inds,UO,false);

            ptch_I=I(ptch_num);
            %ptch_k=K(ptch_num);
            %ptch_c=ptch_counts(patch_num);

            w_I=weights_I(ptch_I);
            w_k=weights_k(ptch_I);
            w_p=weights_p(ptch_num);

            w_t=w_I + w_k + w_p;
            for j = 1:size(inds,1)
                w_pot_c = weight_inds_counts(j);
                w = 1./(w_t + w_pot_c);
                inds_w{j}(inds_w_ptch) = w;
            end

        end
        smp_inds=zeros(size(inds),1);
        for i =1:size(inds,1)
            ind=inds{i};
            % XXX update list
            w=inds_w{j}./sum(inds_w{j});
            smp_inds(i)=randsample(ind,1,true,w);
        end

    end
end
end
