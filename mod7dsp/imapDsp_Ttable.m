classdef imapDsp_Ttable < handle
methods
%% MAIN
    % XXX  load ptch_src
    % XXX  rm ptch_src
    function obj=get_table_row(obj)
        S=take_patch_info(obj)
        [obj.row,obj.key]=struct2row(S);
    end
    function S=take_patch_info(obj)
        S=struct;

        S.D=obj.ptch.name; %D
        S.P=obj.ptch.srcInfo.P;
        S.I=obj.ptch.srcInfo.I;
        S.k=obj.ptch.srcInfo.k;
        S.B=obj.ptch.srcInfo.B;
        S.S=obj.ptch.srcInfo.S;
        S.PctrRC=obj.ptch.srcInfo.PctrRC;
        S.hash=obj.hashes.dsp;
        S.dspGenHash=obj.hash; % NOTE
        S.display=DISPLAY.get_name_from_display(obj.ptch.display);
        S.LExyz=obj.subjInfo.LExzy;
        S.RExyz=obj.subjInfo.RExzy;

        S.WinXYZm=obj.ptch.win.posXYZm;
        S.WinPszRCm=obj.ptch.win.WHm;
        S.trgtDSP=obj.ptch.trgtInfo.trgtDsp;
        % XXX double check these
        S.trgtXYZm=obj.ptch.trgtInfo.posXYZm;
        S.focXYZm=obj.ptch.focInfo.posXYZm;

    end
%% SAVE
    function []=save_table(obj)
        fname=get_table_fname_f(obj.hashes.database,obj.hash);
        table=obj.table;
        key = obj.key;
        save(fname,'table','key');
    end
    function get_table_fname(obj)
        imapDSP.get_table_fname_f(obj.hashes.database,obj.hash)
    end
end
methods(Static=true)
    function [table,key]=load_table_f(database,hash)
        fname=imapDSP.get_table_fname_f(database,hash);
        load(fname);
    end
    function fname=get_table_fname_f(database,hash)
        dire=ptch.get_directory_dsp_p(database,hash);
        name='_table_';
        fname=[dire name];
    end
end
end
