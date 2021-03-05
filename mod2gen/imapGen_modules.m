classdef imapGen_modules < handle
methods
    function Ximg = X_disparity_contrast(obj,setParams)
        % MAPS:   XYZ
        % setParams: WK, KERNSZ,
        % OTHER:  LORR, IPDm % NOTE NEEDED TO COMPUTE LATER

        kernSz=setParams.kernSz;
        Wk=setParams.Wk;
        if isfield(setParams,'dnk')
            dnk=setParams.dnk;
        else
            dnk=1;
        end

        LorR=obj.LorR;
        IPDm=obj.db.IPDm;
        xyz=obj.im.xyz{obj.k};
        Ximg=imapGen_modules.disparity_contrast(xyz,Wk,kernSz,IPDm,LorR,dnk);
    end
    function Ximg = X_disparity_contrast_2(obj,setParams)
        % MAPS:   XYZ
        % setParams: WK, KERNSZ,
        % OTHER:  LORR, IPDm

        kernSz=setParams.kernSz;
        Wk=setParams.Wk;
        if isfield(setParams,'dnk')
            dnk=setParams.dnk;
        else
            dnk=1;
        end

        LorR=obj.LorR;
        IPDm=obj.db.IPDm;
        xyz=obj.im.xyz{obj.k};
        Ximg=imapGen_modules.disparity_contrast_2(xyz,Wk,kernSz,IPDm,LorR,dnk);
    end
end
methods(Static=true)
    function Ximg=disparity_contrast(xyz,Wk,kernSz,IPDm,LorR,dnk)
        % NOTE in arcmin

        W      = cosWindow(kernSz,Wk/100); %W100
        W      = W./sum(W(:));
        if dnk ~=1
            for i = 1:size(xyz,3)
                xyz(:,:,i)=imresize(imresize(xyz(:,:,i),1/dnk,'bilinear'),size(xyz(:,:,i)),'bilinear');
            end
        end
        vrgImg = 60*vergenceFromRangeXYZVec(LorR,IPDm,xyz);
        Ximg   = single(real(rmsDeviationLoc(vrgImg,W)));
    end
    function Ximg=disparity_contrast_2(xyz,Wk,kernSz,IPDm,LorR,dnk)
        % NOTE in arcmin
        %
        W      = cosWindow(kernSz,Wk/100); %W100
        W      = W./sum(W(:));
        if dnk ~=1
            for i = 1:size(xyz,3)
                xyz(:,:,i)=imresize(imresize(xyz(:,:,i),1/dnk,'bilinear'),size(xyz(:,:,i)),'bilinear');
            end
        end
        vrgImg = 60*vergenceFromRangeXYZVec(LorR,IPDm,xyz);
        Ximg   = single(real(rmsDeviationLoc(rmsDeviationLoc(vrgImg,W),W)));
    end

    function params=params_disparity_contrast()
        params=struct();
        params.maps      ={'xyz'};
        params.setParams ={'Wk','kernSz','dnk'};
        params.objParams ={};
        params.dbParams  ={'IPDm'};
        params.bLorR     =1;
        params.units     ='arcmin';
        params.bRmBorder   =1;
        params.borderMult  =0.50;
    end
    function params=params_disparity_contrast_2()
        params=imapGen_modules.params_disparity_contrast();
        params.borderMult  =0.75;
    end

end
end
