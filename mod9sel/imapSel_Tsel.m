classdef imapSel_Tsel < handle
methods
end
methods(Static=true)
    function [selTable,selKey]=get_sel_table(smp_inds, blkTable,blkKey, dspTable,dspKey)
        % DONE
        % large final table
        % blkKey={'mode','lvlInd','blk','trl','intrvl','cmpInd','cmpNum'};
        selKey={'I','D','lvlInd','blk','trl','intrvl','cmpInd','cmpNum','fname'};
        selTable=cell(size(smpInds,1),9);
        Iind=vertcat(dspTable{:,(ismember(dspKey,'I'))});
        Dind=vertcat(dspTable{:,(ismember(dspKey,'D'))});

        modeInd=vertcat(blkTable{:,(ismember(blkKey,'mode'))});
        lvlInd=vertcat(blkTable{:,(ismember(blkKey,'lvlInd'))});
        blkInd=vertcat(blkTable{:,(ismember(blkKey,'blk'))});
        trlInd=vertcat(blkTable{:,(ismember(blkKey,'trl'))});
        intrvlInd=vertcat(blkTable{:,(ismember(blkKey,'intrvl'))});
        cmpInd=vertcat(blkTable{:,(ismember(blkKey,'cmpInd'))});
        cmpNumInd=vertcat(blkTable{:,(ismember(blkKey,'cmpNumInd'))});

        selKey(:,1)=dspTable(smp_inds,Iind);
        selKey(:,2)=dspTable(smp_inds,Dind);

        selKey(:,3)=blkTable(:,modeInd);
        selKey(:,4)=blkTable(:,lvlInd);
        selKey(:,5)=blkTable(:,blkInd);
        selKey(:,6)=blkTable(:,trlInd);
        selKey(:,7)=blkTable(:,intrvlInd);
        selKey(:,8)=blkTable(:,cmpInd);
        selKey(:,9)=blkTable(:,cmpNumInd);

    end
end
end
