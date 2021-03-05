classdef imapSel_Tblk < handle
methods
end
methods(Static=true)
    function [table,key]=get_blk_table(modes,nBlkPerLvl,nStd,nTrlPerLvl,nCmpPerLvl,nIntrvlPerTrl,Sd)
        % DONE
        %
        %modes=[1 2];
        %nBlkPerLvl=5;
        %nStd=5;
        %nTrlPerLvl=900;
        %nCmpPerLvl=9;
        %nIntrvlPerTrl=2;
        %Sd=1;
        %%%%

        key={'mode','lvlInd','blk','trl','intrvl','cmpInd','cmpNum'};

        nModes=numel(modes);
        nBlk=nModes*nStd*nBlkPerLvl; %50
        nTrlPerBlk=nTrlPerLvl/nBlkPerLvl; % 180

        %nIntrvlAll=nModes*nStd*nBlkPerLvl*nTrlPerBlk*nIntrvlPerTrl;
        %nCmpAll=nModes*nStd*nBlkPerLvl*nTrlPerBlk*(nIntrvlPerTrl-1);
        table=distribute(modes,1:nStd,1:nBlkPerLvl,1:nTrlPerBlk,1:nIntrvlPerTrl); % 18000

        rng(Sd);

        cmpInd=get_cmpInd(nCmpPerLvl,nTrlPerBlk,nBlk,nIntrvlPerTrl);
        cmpNum=get_cmp_num(nTrlPerBlk,nBlk,nIntrvlPerTrl);

        table=[table cmpInd cmpNum];

        function c=get_cmpInd(nCmpPerLvl,nTrlPerBlk,nBlk,nIntrvlPerTrl)
            c=repmat(repelem(1:nCmpPerLvl,1,nTrlPerBlk/nCmpPerLvl),nBlk,1);
            c=transpose(shuffle_within_rows(c));
            c=c(:);
            counts=hist(c(1:nTrlPerBlk),unique(c(1:nTrlPerBlk)));
            if ~isuniform(counts)
                error('something bad happend')
            end
            c=repelem(c,nIntrvlPerTrl,1);
        end
        function c=get_cmp_num(nTrlPerBlk,nBlk,nIntrvlPerTrl)
            c=repmat((1:nIntrvlPerTrl),nTrlPerBlk*nBlk,1);
            c=transpose(shuffle_within_rows(c));
            c=c(:);
        end
        function B=shuffle_within_rows(A)
            [M,N] = size(A);
            % Preserve the row indices
            rowIndex = repmat(transpose(1:M),[1 N]);
            % Get randomized column indices by sorting a second random array
            [~,randomizedColIndex] = sort(rand(M,N),2);
            % Need to use linear indexing to create B
            newLinearIndex = sub2ind([M,N],rowIndex,randomizedColIndex);
            B = A(newLinearIndex);
        end
    end
end
end
