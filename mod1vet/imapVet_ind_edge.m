classdef imapVet_ind_edge < handle & imapVet_ind_plot
methods
    function obj = vet_edge(obj,bV,p)
        if ~exist('var','bV') || isempty(obj.bV)
            % TODO ADD THIS TO OPTS SOMEHOW
            bV=0;
        end

        if exist(p,'var') && isa(p,'pr')
            obj.p=p;
            obj.bp=1;
        else
            obj.bp=0;
        end

        if ~any(obj.bVetEdge)
            return
        end

        if obj.bStart
            % adopt from gdMap
            obj.bStart=1;
        else
            % continue
            obj.gdMap{1}=obj.dnMap;
        end

        obj.get_indeces_from('map',1,0,0);%get cps from map ind bV bCp
        if obj.bVetEdge(1)
            obj.vet_edge_helper(1,bV);
            obj.get_indeces_from('map',1,bV,obj.bVetEdge(2));%get cps from map ind bV bCp
        elseif obj.bVetEdge(2)
            obj.vet_edge_helper(2,bV);
        end

        if bV
            mfld='tstMap';
            cfld='tstMap';
        else
            mfld='gdMap';
            cfld='dnMap';
        end

        if all(obj.bVetEdge)
            bimap=obj.(mfld){1};
            obj.get_indeces_from('map',2,bV,1);%get cps from map ind bV bCp
            obj.(cfld)=obj.(mfld){1} & bimap;
        elseif obj.bVetEdge(2)
            obj.get_indeces_from('map',2,bV,1);%get cps from map ind bV bCp
            obj.(cfld)=obj.(mfld){1};
        elseif obj.bVetEdge(1)
            obj.(clfd)=obj.(mfld){1};
        end
    end
    function obj = vet_edge_main(obj,ind,bV)
        %
        if bV
            mfld='tstMap';
        else
            mfld='gdMap';
        end
        pixrc=[];
        % TODO ADD IN VEC RUNLENGTH ENCODER
        for r = 1:obj.IszRC(1)
            [out,width]=obj.vet_edge_main(mfld,obj.(mfld){ind}(r,:),r,ind);
            pixrc=[pixrc; out];
            %wdths=[wdths; width];
        end

        %MAKE SURE THESE REGIONS ARE WITHIN RANGE
        ind=pixrc(:,2)<=obj.IszRC(2) & pixrc(:,1)<=obj.IszRC(1);
        pixrc(ind,:)=[];
        if isempty(pixrc)
            obj.returnFlag=1;
            return
        end

        v=obj.ctredgFORorEITHERorAGAINST{ind};
        vetimap=obj.blankmap;
        pxInd=sub2ind(obj.IszRC,pixrc(:,1),pixrc(:,2));
        vetimap(pxInd)=1;
        if strcmp(v,'AGAINST')
            obj.(mfld){ind}=obj.(mfld){ind} & ~vetimap;
        elseif strcmp(v,'FOR')
            obj.(mfld){ind}=obj.(mfld){ind} & ~vetimap;
        elseif strcmp(v,'EITHER')
            obj.(mfld){ind}=obj.(mfld){ind} | vetimap;
        end

    end
    function [gdRC,width]=vet_edge_helper(obj,row,rind,ind)
        obj.continueFlag=0;

        %COUNT RUNS OF MAP
        [indChg,runVal,runCnt]=runLengthEncoder(row);

        %INEX OF RUN STARTS
        begs=indChg(1:end-1);
        begs=begs(runVal==1); %first Map pixel

        %WIDTHS OF RUNS
        width=runCnt(runVal==1);

        %INDEX OF RUN ENDS
        ends=begs+width-1;  %Last Map pixel
                            %minus 1 because begs is index 1

        %CONDITION WIDTHS AND BEGINNINGS ON BEING LARGER THAN minPixMap
        valind = (width>=obj.minMaxPixWidth(ind,1) & width<=obj.minMaxPixWidth(ind,2));
        begs=begs(valind);
        ends=ends(valind);
        width=width(valind);

        %MID POINT OF RUN
        % NOTE floor
        ctr=floor(width./2+1);

        if strcmp(obj.ctrORedgeORnon{ind},'edg') && ind==1
            val=begs(:);
        elseif strcmp(obj.ctrORedgeORnon{ind},'edg') && ind==2
            val=ends(:);
        elseif strcmp(obj.ctrORedgeORnon{ind},'ctr')
            val=begs(:)+ctr(:);
        elseif strcmp(obj.ctrORedgeORnon{ind},'fgnd') && ind==1
            val=ends(:)+1;
        elseif strcmp(obj.ctrORedgeORnon{ind},'fgnd') && ind==2
            val=begs(:)-1;
        else
            error('Unhandled ctrORedgeORnon value');
        end

        n=length(val);
        gdRC=[repmat(rind,n,1), val];
    end
end
end
