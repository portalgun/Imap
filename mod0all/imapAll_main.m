classdef imapAll_main < handle
methods
    function obj=run(obj)
        obj.main();
    end
    function obj=run_module(obj,module)
        % XXX meth here?
        meth=['get_' module '_params'];
        if ismethod(obj,meth)
            obj.(meth)();
        end
        obj.MODS.(module).run();
    end
    function obj=rerun_module(obj,mod)
        i=ismember(obj.modules,mod);
        obj.runCodes(i)=1;
        obj.init_mod(mod);
        obj.main();
    end
end
methods(Access=protected)
    % RUN CODES
    % -1 -
    %  0 skip
    %  1 continue
    %  2 rerun/run all
    %  3 prompt
    function obj=main(obj)
        for i = 1:length(obj.modules)
            module=obj.modules{i};
            if obj.runCodes(i)==0
                continue
            end

            obj.check_opts_change(i);

            obj.run_module(module);
            obj.mark_complete(module);

            if strcmp(module,'bin') & obj.bStopAtSmp
                obj.bStopAtSmp=0;
                modsinit=transpose(find(obj.runCodes~=0));
                if ~isempty(modsinit)
                    display('Now have edges -> initializing smp onwards...')
                    obj.init_mods(modsinit);
                end
            end
        end

    end
    function obj=mark_complete(obj,mod)
        i=ismember(obj.modules,mod);
        obj.runCodes(i)=0;
        obj.MODS.(mod)=[]; % clear once done
    end
    function obj=check_opts_change(obj,i)
        module=obj.modules{i};
        if ~isequal(obj.Opts.(module),obj.OrigOpts.(module))
            warning(['Options for ' module ' have changed since init. Reinitializing.']);
            obj.bInit.(module)=0;
            obj.OrigHash=obj.hashes.(module);
            obj.hashes.(module)='';
            obj.init_mod(module);
            obj.cleanup_dir(obj.database,module,obj.OrigHash);
            if i < length(obj.modules) && ~iesqual(obj.OrigHash, obj.hashes.(module));
                warning(['Hash for ' module ' has changed. Reinitializing subsequent modules.'])
                modnums=i+1:length(obj.modules)
                for j = modnums
                    mod=obj.modules{j};
                    obj.cleanup_dir(mod,obj.hashes.(mod));
                end
                obj.init.mods(modnums);
            end
        end
    end
end
end
