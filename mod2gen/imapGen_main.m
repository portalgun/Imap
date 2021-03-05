classdef imapGen_main < handle
methods
    function obj=run(obj)
        obj.main();
    end
end
methods(Access=protected)
    function obj=main(obj)
        obj.check_all_fnames();
        obj.blankmap=double(obj.blankmap);
        p=pr(obj.nImg,1,'Indexing by X');
        for ii = 1:obj.nImg
            obj.I=obj.imgNums(ii);
            p.u();

            if all(obj.imExists(ii,2))
                continue
            end
            if obj.plotOpts.bProg
                obj.get_pht(obj.I);
            end

            for kk=1:obj.nLandR
                obj.k=kk;
                obj.LorR=obj.LandR{kk};
                obj.notLorR=obj.notLandR{kk};

                obj.im=obj.get_images();
                obj.gen_map();

                obj.plot_prog();
                obj.save();
            end
        end
        p.c();
    end

    function obj=gen_map(obj)
        meth=obj.genOpts.type.name;
        setParams=obj.genOpts.type.setParams;
        XimgM=obj.(meth)(setParams);
        ind=true(size(XimgM));

        %CONDITION UPON OTHER VALUES SPECIFIED BY XTYPEL AND THEIR MINMAX
        for l = 1:obj.genOpts.nL
            meth=obj.genOpts.typeL{l}.name;
            setParams=obj.genOpts.typeL{l}.setParams;
            mm=obj.genOpts.typeL{l}.minMax;
            x=obj.(meth)(setParams);
            ind=(ind & (x >= mm(1) & x <= mm(2)));
        end

        obj.gen=obj.blankmap;
        obj.gen(ind)=XimgM(ind);
        obj.gen=single(obj.gen);
        if obj.genOpts.type.bRmBorder
            kw=ceil(setParams.kernSz(2)*obj.genOpts.type.borderMult);
            kh=ceil(setParams.kernSz(1)*obj.genOpts.type.borderMult);
            W=size(obj.gen,2);
            H=size(obj.gen,1);

            l=1:kw;
            r=W-kw:W;
            t=1:kh;
            b=H-kh:H;
            obj.gen(:,l)=nan;
            obj.gen(:,r)=nan;
            obj.gen(t,:)=nan;
            obj.gen(b,:)=nan;
        end

    end
end
end
