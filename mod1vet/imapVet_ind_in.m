classdef imapVet_ind_in < handle & imapVet_ind_plot
properties(Hidden=true)
    O % objects
    Ocentrl % central object
    OsigInd
    OcentrlInd
    nOsig  % number of significant
    vert
    hori

    MapcpKernRadHW
    MapkernRadHW
    MapkernArea

    blankPatch
    j
    r
    c

    tstWin
    win
    winsz
    ctrRC
    ctrind

    ll
    cr
    cc
    or
    oc

end
methods
    function obj=vet_in(obj,anch,bPlot, p)
        if exist('p','var') && isa(p,'pr')
            obj.p=p;
            obj.bp=1;
        else
            obj.bp=0;
        end

        [k,nk]=obj.xyz.get_k(anch);
        obj.mod_init();
        bBoth=all(obj.bVetInVec(k,:));

        % VEC A
        if obj.bVetInVec(k,k)
            obj.message('In Vec',k,k);
            obj.vet_in_vec(k,k);
        end
        if bBoth
            obj.update_CP_from_anch(k);
        else
            obj.update_anch_from_map(k);
            obj.update_vet_from_map(k);
            return
        end
        if obj.returnFlag; return; end

        if ~bBoth & bPlot; obj.debug_plot('In Vec',34,k); end

        % VEC B
        if obj.bVetInVec(k,nk)
            obj.message('In Vec',k,nk);
            %obj.vet_in_vec(k, nk);
            obj.update_anch_from_CP(k);
        end
        if obj.returnFlag; return; end

        if bPlot; obj.debug_plot('In Vec',34,k); end

        bBoth=all(obj.bVetWn(k,:));

        % PIX A
        if obj.bVetObj(k,k)
            obj.message('In Pix',k,k);
            obj.vet_in_pix(k, k);
        end
        if bBoth
            obj.update_CP_from_anch(k);
        else
            obj.update_anch_from_map(k);
            obj.update_vet_from_map(k);
            return
        end
        if obj.returnFlag; return; end

        if ~bBoth & bPlot; obj.debug_plot('In Pix',35,k); end

        % PIX B
        if obj.bVetObj(k,nk)
            obj.message('In Pix',k,nk);
            %obj.vet_in_pix(k, nk);
            obj.update_vet_from_CP(k);
        end

        if bPlot; obj.debug_plot('In Pix',35,k); end
    end
    function obj=vet_in_pix(obj,anch,cp)
        obj.vet_in_apply_border(anch,cp);
        gdMap=zeros(size(obj.gdMap{anch}{cp}));

        obj.winsz=round(obj.MapkernRadHW*2)+1; % size of window
        obj.ctrRC=round(obj.winsz/2);
        obj.ctrind=sub2ind(obj.winsz,obj.ctrRC(1),obj.ctrRC(2)); % center of window index

        for jj = 1:size(obj.gdInd{anch}{cp},1)
            obj.j=obj.gdInd{anch}{cp}(jj);
            obj.r=obj.gdRC{anch}{cp}(jj,1);
            obj.c=obj.gdRC{anch}{cp}(jj,2);

            obj.vet_in_pix_main(anch,cp);
            if obj.continueFlag==1;  obj.continueFlag=0; continue; end

            gdMap(obj.j)=1;
        end
        if ~any(gdMap)
            obj.returnFlag=1;
            return
        end
        obj.gdMap{anch}{cp}=gdMap;
    end
%% MAIN
    function obj=vet_in_vec(obj,anch,cp)
        if obj.bVetCntrNeighb(anch,cp)
            obj.vet_vec_center_neighboring(anch,cp);
        end
    end
    function obj=vet_in_pix_main(obj,anch,cp)
    % MORE SPECIFIC - PIXEL BY PIXEL
    % NOTE this method takes much longer
    %
        obj.get_window(anch,cp);
        if obj.continueFlag==1; return; end

        %obj.plot_win(anch,cp); % NOTE

        % CENTRAL OBJECT VETS
        if obj.bVetObj(anch,cp)
            obj.get_O(anch,cp);
            if obj.continueFlag==1; return; end

            obj.get_Ocentrl(anch,cp);
            if obj.continueFlag==1; return; end

            obj.get_Osig(anch,cp);
            obj.get_central_Osig(anch,cp);

            if obj.bVetMaxNumSig(anch,cp)
                obj.vet_max_num_sig_zones(anch,cp);
                if obj.continueFlag==1; return; end
            end
            if obj.bVetSigCntr(anch,cp)
                obj.vet_sig_central_pixel(anch,cp); % Ocentrl
                if obj.continueFlag==1; return; end
            end
            if obj.bVetWidth(anch,cp)
                obj.vet_width(anch,cp); % Ocentrl
                if obj.continueFlag==1; return; end
            end
            if obj.bVetHeight(anch,cp)
                obj.vet_height(anch,cp); % Ocentrl
                if obj.continueFlag==1; return; end
            end
            if obj.bVetBranch(anch,cp)
                obj.vet_branching(anch,cp); %Ocentrl
                if obj.continueFlag==1; return; end
            end
            if obj.bVetCntrNeighbZone(anch,cp)
                obj.vet_center_neighboring_zone(anch,cp); %Ocentrl
                if obj.continueFlag==1; return; end
            end
            if obj.bVetNeighbZone(anch,cp)
                obj.vet_neighboring_zone(anch,cp); %Ocentrl
                if obj.continueFlag==1; return; end
            end
            if obj.bVetNeighbZoneVert(anch,cp)
                obj.vet_neighboring_zone_vert(anch,cp); %Ocentrl
                if obj.continueFlag==1; return; end
            end
            if obj.bVetNeighbZoneHori(anch,cp)
                obj.vet_neighboring_zone_hori(anch,cp); %Ocentrl
                if obj.continueFlag==1; return; end
            end
        end

        if obj.bVetDensity(cp)
            obj.vet_density(anch,cp);
            if obj.continueFlag==1; return; end
        end

    end
%% MODULES
    function obj=vet_density(obj,anch,cp)
    % window
        %CALCULATE DENSITY
        tmp=obj.tstMap{cp}(obj.vert{anch,cp},obj.hori{anch,cp});
        ratio(obj.j)=tmp(:)./obj.MapkernArea(cp);

        %VALID IF DENSITY REQUIREMENT MET
        if ratio(obj.j)<obj.minDensity(cp)
            obj.continueFlag=1;
        end
    end

    function obj=vet_max_num_sig_zones(obj,anch,cp)
    %DO NOT INCLUDE PATCHES WITH MORE THAN SPECIFIED SIGNIFICANT Map ZONES
        %DO NOT INCLUDE PATCHES WITH MORE THAN SPECIFIED SIGNIFICANT Map ZONES
        if obj.nOsig{cp}>obj.nSigThresh(cp)
            obj.continueFlag=1;
        end
    end

    function obj=vet_sig_central_pixel(obj,anch,cp)

        %FIND MOST CENTRAL Map ZONE
        if any(obj.OcentrlInd{cp} & ~obj.OsigInd{cp})
            obj.continueFlag=1;
        end
    end
    function obj=vet_width(obj,anch,cp)
    %DISCARD PATCHES THAT DO NOT MEET WIDTH REQUIREMENTS FOR CENTRAL OBJECT
    % obj
        wdths=sum(obj.Ocentrl{cp},2);
        if obj.bWidthTwoWay(anch,cp)==1
            %COUNT NUMBER OF ROWS THAT MEET WIDTH REQ
            count=sum(wdths>=(obj.minMaxPixWidth(1)-obj.widthBuffer(cp)) & wdths <= (obj.minMaxPixWidth(2)+obj.widthBuffer(cp)));
        elseif obj.bWidthTwoWay(anch,cp)==0
            %COUNT NUMBER OF ROWS THAT MEET WIDTH REQ
            count=sum(wdths>=(obj.minMaxPixWidth(1)-obj.widthBuffer(cp)));
        else
            % XXX ?
            return
        end
        if count<obj.widthCount(cp)-obj.widthCountBuffer(cp)
            obj.continueFlag=1;
        end

    end
    function obj=vet_height(obj,anch,cp)
    %DISCARD PATCHES THAT DO NOT MEET WIDTH REQUIREMENTS FOR CENTRAL OBJECT
    % obj
        hghts=sum(obj.Ocentrl{cp},2);
        if obj.bHeightTwoWay(anch,cp)==1
            %COUNT NUMBER OF ROWS THAT MEET Height REQ
            count=sum(hghts>=(obj.minMaxPixHeight(1)-obj.widthBuffer(cp)) & hghts <= (obj.minMaxPixHeight(2)+obj.widthBuffer(cp)));
        elseif obj.bHeightTwoWay(anch,cp)==0
            %COUNT NUMBER OF ROWS THAT MEET Height REQ
            count=sum(hghts>=(obj.minMaxPixHeight(1)-obj.widthBuffer(cp)));
        else
            % XXX?
            % return
        end

        if count<obj.heightCount(cp)-obj.heightCountBuffer(cp)
            obj.continueFlag=1;
        end
    end
    function obj=vet_branching(obj,anch,cp)
    %DISCARD PATCHES WITH BRANCHING CENTRAL Map ZONES
    % obj
        [~,~,indOneChg]=runLengthEncoderVec(obj.Ocentrl{cp},2);
        if any(cellfun(@(x) length(x)>1,indOneChg))
            obj.continueFlag=1;
        end
    end
    function obj=vet_neighboring_zone_hori(obj,anch,cp)
    %DISCARD PATCHES THAT HAVE A SINFICIANT ZONE HORIZONTALLY TOO CLOSE TO THE CENTRAL ZONE
        if isempty(obj.oc) || isempty(obj.cc)
            obj.continueFlag=1;
            return
        end

        %other
        dist=abs(obj.oc-obj.cc);
        if any(dist < obj.minZoneSepHori(cp))
            obj.continueFlag=1;
        end

    end
    function obj=vet_neighboring_zone_vert(obj,anch,cp)
    %DISCARD PATCHES THAT HAVE A SINFICIANT ZONE HORIZONTALLY TOO CLOSE TO THE CENTRAL ZONE
        if isempty(obj.or) || isempty(obj.cr)
            obj.continueFlag=1;
            return
        end


        dist=abs(obj.or-obj.cr);
        if any(dist < obj.minZoneSepVert(cp))
            obj.continueFlag=1;
        end

    end
    function obj=vet_neighboring_zone(obj,anch,cp)
    % central
        if isempty(obj.or) || isempty(obj.cr)
            obj.continueFlag=1;
            return
        end

        %other
        dist=sqrt((obj.or-obj.cr).^2 + (obj.oc-obj.cc).^2);

        if any(dist < obj.minZoneSep(cp))
            obj.continueFlag=1;
        end
    end
    function obj=vet_center_neighboring_zone(obj,anch,cp)
        %center pixel
        if isempty(obj.or)
            obj.continueFlag=1;
            return
        end

        dist=sqrt((obj.or-obj.ctrRC(1)).^2 + (obj.oc-obj.ctrRC(2)).^2);

        if any(dist < obj.minZoneCntrSep(cp))
            obj.continueFlag=1;
        end
    end
%% VEC
% NOTE SLOW, but faster than by pix
    function obj=vet_vec_center_neighboring(obj,anch,cp)
        im = imdilate(obj.tstMap{cp}, strel('sphere',obj.minCntrSep(cp)));
        %figure(1)
        %imagesc(obj.tstMap{anch})
        %figure(2)
        %imagesc(im)
        obj.gdMap{anch}{cp}=obj.gdMap{anch}{cp} & ~im;
    end
    function obj=vet_vec_center_neighboring_hori(obj,anch,cp)
        % XXX Add
        im = imdilate(obj.tstMap{cp}, strel('rect',[1 obj.minCntrSep(cp)]));
        obj.gdMap{anch}{cp}=obj.gdMap{anch}{cp} & ~im;
    end
    function obj=vet_vec_center_neighboring_vert(obj,anch,cp)
        % XXX Add
        im = imdilate(obj.tstMap{cp}, strel('rect',[obj.minCntrSep(cp) 1]));
        obj.gdMap{anch}{cp}=obj.gdMap{anch}{cp} & ~im;
    end
    function obj=vet_vec_center_neighboring_square(obj,anch,cp)
        % XXX Add
        im = imdilate(obj.tstMap{cp}, strel('rect',[obj.minCntrSep(cp) 1]));
        obj.gdMap{anch}{cp}=obj.gdMap{anch}{cp} & ~im;
    end

%% GET
    function obj=get_O(obj,anch,cp)
        CC=bwconncomp(obj.tstWin);
        obj.O{cp}=CC.PixelIdxList;
        if isempty(obj.O{cp})
            obj.continueFlag=1;
        end
    end
    function obj=get_Ocentrl(obj,anch,cp)
        obj.OcentrlInd{cp}=cellfun(@(x) any(ismember(obj.ctrind,x)),obj.O{cp});
        if sum(obj.OcentrlInd{cp})==0
            obj.continueFlag=1;
            return
        end
        obj.ll=obj.O{cp}{obj.OcentrlInd{cp}};
        obj.Ocentrl{cp}=obj.blankPatch{cp};
        obj.Ocentrl{cp}(obj.ll)=1;

    end
    function obj=get_Osig(obj,anch,cp)
        %GET SIG
        nPixO=cellfun(@numel, obj.O{cp}); % total number of pixels per region
        obj.OsigInd{cp}=nPixO>obj.nPixSigThresh(cp); % significant index to O
        obj.nOsig{cp}=sum(obj.OsigInd{cp}); % number of significant map regions
    end
    function obj=get_central_Osig(obj,anch,cp)
        % GET CENTRAL SIG
        [obj.cr,obj.cc]=ind2sub(obj.PszRC(cp,:),obj.ll);

        % NON CNETRAL SIG
        inds=[obj.O{cp}{obj.OsigInd{cp} & ~obj.OcentrlInd{cp}}]; % not central sig
        [obj.or, obj.oc]=ind2sub(obj.PszRC(cp,:),inds);
    end
    function obj=get_window(obj,anch,cp)
    % 1.21e-4 sec/run
        H=obj.MapkernRadHW(cp,1);
        W=obj.MapkernRadHW(cp,2);

        v=round(cell2mat( arrayfun(@(x) x-H:x+H, obj.r, 'UniformOutput',false) ));
        h=round(cell2mat( arrayfun(@(x) x-W:x+W, obj.c, 'UniformOutput',false) ));

        %DO NOT INCLUDE PATCHES OUTSIDE OF RANGE
        if any(v<=0) || any(h<=0) || max(v)>=obj.IszRC(1) || max(h)>=obj.IszRC(2)
            obj.continueFlag=1;
        else
            obj.vert{anch,cp}=v;
            obj.hori{anch,cp}=h;
        end
        obj.tstWin=obj.tstMap{cp}(obj.vert{anch,cp},obj.hori{anch,cp});
    end
    function obj=get_window_CP(obj,anch,cp)
        v=round(cell2mat( arrayfun(@(x) x-H:x+H, obj.r, 'UniformOutput',false) ));
        h=round(cell2mat( arrayfun(@(x) x-W:x+W, obj.c, 'UniformOutput',false) ));
    end
    function obj=get_window_alt(obj,anch,cp)
    % 0.069 sec/run
        H=obj.MapkernRadHW(cp,1);
        W=obj.MapkernRadHW(cp,2);

        bInd= abs(obj.Y-obj.ctrRC(1)) <= H & abs(obj.X-obj.ctrRC(2)) <= W;
        if sum(bInd,'all') < numel(obj.X)
            obj.continueFlag=1;
        end
        [obj.vert{cp},obj.hori{cp}]=find(bInd);
    end
    function obj=vet_in_apply_border_all(obj)
        for anch=1:2
        for cp = 1:2
            obj.vet_in_apply_border(anch,cp);
        end
        end
        obj.update_anch_from_map(1);
        obj.update_CP_from_map(1);

        obj.update_anch_from_map(2);
        obj.update_CP_from_map(2);
    end
    function obj=vet_in_apply_border(obj,anch,cp)
        H=obj.MapkernRadHW(cp,1);
        W=obj.MapkernRadHW(cp,2);
        obj.gdMap{anch}{cp}(:,1:W)=0;
        obj.gdMap{anch}{cp}(:,end-W:end)=0;
        obj.gdMap{anch}{cp}(1:H,:)=0;
        obj.gdMap{anch}{cp}(:,end-H:end)=0;

        obj.update_from_map(anch,cp);
    end
    function obj=plot_win(obj,anch,cp)
        LandR='LR';
        if isnumeric(anch)
            anch=LandR(anch);
        end
        if isnumeric(cp)
            cp=LandR(cp);
        end
        titl=['Tst Img ' num2str(obj.xyz.I) newline 'Anchor ' anch ' CP ' cp ];
        figure(19); hold off
        imagesc(obj.tstWin); hold on
        plot(obj.ctrRC(2), obj.ctrRC(1), '.y');
        formatImage();
        formatFigure(num2str(obj.c),num2str(obj.r),titl);
        drawnow;
    end
end
end
