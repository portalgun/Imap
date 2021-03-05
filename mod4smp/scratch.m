scratch
    function obj=sample_double(obj)
        % DAVE MAX SAMPLING METHOD

        K=get_LorR_first(obj);

        % XXX need to add in buffering
        [  indA,   indB    ...
           countA, countB] ...
                                   = samplePatchCentersMax2(...
                                           obj.PctrInd{K(1)}  ...
                                          ,obj.PctrInd{K(2)}  ...
                                          ,obj.xyz.cpLookup{K(1)}  ...
                                          ,obj.xyz.cpLookup{K(2)}  ...
                                          ,obj.indLookup ...
                                          ,obj.IszRC ...
                                          ,obj.PszXY ...
                                          ,obj.nSmpPerBin ...
                                          ,obj.overlapPix ...
                                          ,obj.rndSd ...
                                          ,obj.PctrIndPri{K(1)} ...
                                          ,obj.PctrIndPri{K(2)} ...
                                          ,obj.bCPoverlap ...
        );
        if ~obj.bBinOverlap
            obj.PctrIndPri{K(1)}=[obj.PctrIndPri{K(1)}; indA];
            obj.PctrIndPri{K(2)}=[obj.PctrIndPri{K(2)}; indB];
        else
            obj.PctrIndPri{K(1)}=indA;
            obj.PctrIndPri{K(2)}=indB;
        end
        obj.smpInd{obj.B, obj.I, K(1)}=indA;
        obj.smpInd{obj.B, obj.I, K(2)}=indB;
        obj.countsBIL(obj.B,obj.I, K(1))=countA;
        obj.countsBIL(obj.B,obj.I, K(2))=countB;
        obj.cumLandRcounts(K(1))=obj.LandRcounts(K(1))+countA;
        obj.cumLandRcounts(K(2))=obj.LandRcounts(K(2))+countB;

        RC=zeros(size(indA,1),2);
        [RC(:,1),RC(:,2)]=arrayfun(@(x) ind2sub(obj.IszRC,x), indA);
        obj.smpRC{obj.B,obj.I,K(1)}=RC;

        RC=zeros(size(indB,1),2);
        [RC(:,1),RC(:,2)]=arrayfun(@(x) ind2sub(obj.IszRC,x), indB);
        obj.smpRC{obj.B,obj.I,K(2)}=RC;

        function K=get_LorR_first(obj)
            if obj.cumLandRcounts(1) > obj.cumLandRcounts(2)
                K=[2 1];
            elseif obj.cumLandRcounts(1) <= obj.cumLandRcounts(2)
                K=[1 2];
            end
        end
    end
