classdef imapCommon_img < handle
methods
    function obj=get_CPs_all_bi(obj)
        obj.xyz.get_CPS_all_bi();
        obj.xyz.get_cpLookup_bi();
    end
    function obj=get_CPs_all(obj,LorR)
        obj.xyz.get_CPS_all_bi(LorR);
        obj.xyz.get_cpLookup(LorR);
    end
    function BitpRC=get_CPs(obj,LorR,PctrRC)
        obj.xyz.get_CPs(LorR,PctrRC,1);
        BitpRC=obj.xyz.get_BitpRC(LorR);
    end
    function obj=get_cpLookups(obj)
        % XXX
        [obj.cpLookup,inds]=obj.get_cpLookup_bi();
        obj.iImapBins{1}=obj.iImapBins{1}(inds{1},:);
        obj.iImapBins{2}=obj.iImapBins{1}(inds{2},:);
    end
    function obj=get_img_db_info(obj)
        % 1 - 5
        %db=obj.get_info();
        db=dbInfo(obj.database);
        obj.IszRC=db.IszRC;
        if isprop(obj,'imgNums') && isempty(obj.imgNums)
            obj.imgNums=db.gdImages;
            obj.nImg=length(obj.imgNums);
        elseif isprop(obj,'imgNums')
            obj.imgNums(ismember(obj.imgNums,db.badImages))=[];
            obj.nImg=length(obj.imgNums);
        end
        if isprop(obj,'blankmap')
            obj.blankmap=false(db.IszRC);
        end
        if isprop(obj,'db')
            obj.db=db;
        end
        if isprop(obj,'indLookup')
            obj.get_indLookup();
        end
        if isprop(obj,'X') && isprop(obj,'Y')
            obj.get_XY();
        end
    end
end
end
