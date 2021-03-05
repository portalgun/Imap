classdef imapVet_main < handle
methods
    function obj = run(obj)
        obj.main();
    end
end
methods(Access=protected)
    function obj = main(obj)
        obj.check_all_fnames();

        obj.prog=pr(obj.nImg,1,[newline 'Vetting Images']);
        for i = 1:obj.nImg
            obj.prog.u();
            obj.I=obj.imgNums(i);

            if all(obj.imExists(i,2))
                continue
            end

            obj.plotOpts.bPlotI=obj.plotOpts.bPlot; % TODO && ismember(obj.I, obj.plotOpts.imgNum)
            if obj.plotOpts.bPlotI
                obj.get_pht();
            end

            if obj.bCP
                obj.get_range_data();
            end
            obj.get_tstMaps(i);

            obj.init_gd_all();
            obj.init_vet();
            obj.vet_maps_order_first();
            obj.vet_maps_LR_first();
            % XXX combine inds

            obj.save_vet();

        end
        obj.prog.c();
    end
end
end
