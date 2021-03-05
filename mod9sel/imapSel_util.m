classdef imapSel_util < handle
methods
    function obj=gen_name_base(obj)
        obj.hash=imapSel.gen_name(obj.prjInfo,obj.mode,[],[]);
    end
    function fnames=load_name_index(obj)
        fnames=ptch.load_name_index(obj.hashes.database,obj.hashes.ptch);
    end
    function obj=get_dsp_table(obj)
        % XXX
        [obj.dspTable, obj.dspKey]= imapDsp.load_table(obj.ptch,obj.hashes.dsp);
    end
end
methods(Static=true)
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
end
