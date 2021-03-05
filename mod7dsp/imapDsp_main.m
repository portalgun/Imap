classdef imapDsp_main < handle
methods
    function obj=run(obj)
        obj.main();
    end
end
methods(Access=protected)
    function obj=main(obj)
        obj.init_all_inds();
        obj.get_ptch_names();

        % loop over lvls
        for p = 1:nPtch
            obj.pind=p;
            obj.get_ptch();
            for i = 1:obj.N
                obj.select_ind_opt();
                obj.selct_ind_hash();
                obj.do_patch();
                obj.save();
                obj.get_table_row();
                obj.table=[table; dsp.row];
            end
        end
        obj.save_table();
        obj.save_all_ind_table();
    end
    function obj=do_patch(obj)
        obj.ptch.init_disp(obj.indOPts.display,...
                           obj.indOpts.subjInfo,...
                           obj.indOpts.winInfo,...
                           obj.indOpts.trgtInfo,...
                           obj.indOpts.focInfo,...
                           obj.indOpts.texInfo,...
                           obj.indOpts.wdwInfo,...
                           obj.indHashes...
                          );
    end
end
end
