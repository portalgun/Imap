[nTrl,nTrlPerBlk,nTrlPerLvl,nBlkPerLvl,nLvl]=parse_nTrl

function [nTrl,nTrlPerBlk,nTrlPerLvl,nBlkPerLvl,nLvl]=parse_nTrl(nTrl,nTrlPerBlk,nTrlPerLvl,nBlkPerLvl,nLvl)
    % XXX
    % nTrl nBlkPerLvl -> nTrlPerBlk, nTrl, nLvl
    % nTrl nTrlPerBlk -> nBlkPerLvl
    %
    %blk, trl, lvl
    nTrl=900;
    nTrlPerBlk=[];
    nTrlPerLvl=[];
    nBlkPerLvl=5;
    nLvl=[];

    for i = 1:2
    % BLK
        if ~isempty(nTrlPerBlk) && ~isempty(nTrl) && isempty(nBlkPerLvl)
            nBlkPerLvl=nTrl/nTrlPerBlk;
        elseif ~isempty(nTrlPerBlk) && ~isempty(nTrl) && ~isempty(nBlkPerLvl) && ~isequal(nTrlPerBlk,nTrl/nBlkPerLvl)
            error('If specifying nTrl & nTrlPerBlock, they must be consistent with nBlkPerLvl')
        end
        if  ~isempty(nBlkPerLvl) && ~isempty(nBlkPerLvl) && isempty(nTrlPerBlk)
            nTrlPerBlk=nTrl/nBlkPerLvl;
        end
        if ~isempty(nBlkPerLvl) && isempty(nTrl)
            nTrl=nTrlPerBlk*nBlkPerLvl;
        end

    % STD
        if ~isempty(nTrlPerLvl) && ~isempty(nTrl) && ~isequal(nTrlPerLvl,nTrl/nLvl)
            error('If specifying nLvl & nTrlPerLvl, they must be consistent with nLvl')
        elseif ~isempty(nTrl) && ~isempty(nLvl) && isempty(nTrlPerLvl)
            nTrlPerLvl=nTrl/nLvl;
        elseif ~isempty(nBlkPerLvl) && ~isempty(nTrlPerLvl) && isempty(nTrlPerBlk)
            nTrlPerBlk=nTrlPerLvl/nBlkPerLvl;
        end
        if ~isempty(nBlkPerLvl) && ~isempty(nTrlPerBlk) && isempty(nTrlPerLvl)
            nTrlPerLvl=nBlkPerLvl*nTrlPerBlk
        end

        if isempty(nLvl) && ~isempty(nTrl) && ~isempty(nBlkPerLvl)
            nLvl=nTrlPerLvl*nBlkPerLvl;
        end
    end
end
