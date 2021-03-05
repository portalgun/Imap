classdef imapAll_mod_init < handle
methods
    function obj=init_mods(obj,mods)
        if ~exist('mods','var') || isempty(mods)
            mods=1:length(obj.modules);
        end

        for i = mods
            obj.bInit.(obj.modules{i})=0;
            obj.completion(i)=0;
            obj.bComplete.(obj.modules{i})=0;
            obj.hashes.(obj.modules{i})='';
        end

        obj.bDoForAll=-1;
        obj.exitflag=0;
        obj.bAdopted=0;
        obj.init_iterate(mods);
        if obj.bAdopted
            obj.init_iterate(mods)
        end
    end
    function obj=init_iterate(obj,mods)
        for i = mods
            if obj.runCodes(i)==0
                continue
            elseif i > 3 && obj.bStopAtSmp
                disp('No edges specified, cannot initialize smp onwards until edges determined (imapBin)')
                break
            end
            obj.init_mod(obj.modules{i});
            if obj.exitflag; return; end
        end
    end
    function obj=init_mod(obj,mod,bRedo)
        if ~exist('bRedo','var') || isempty(bRedo)
            bRedo=0;
        end
        obj.(mod);

        obj.OrigOpts.(mod)=obj.Opts.(mod);
        obj.OrigPlotOpts.(mod)=obj.plotOpts.(mod);
        obj.bInit.(mod)=1;

        if ismember(mod,{'dmp_pch','dmp_dsp'})
            return
        end

        hash=obj.MODS.(mod).hash;
        obj.hashes.(mod)=hash;
        if bRedo
            return
        end
        exi=imapCommon.exist_project_DB(hash,obj.alias,obj.database,mod);

        % CODES
        % 0 - nothing exists already ->  new stuff
        % 1 - everything matches
        % 2 - different hash
        % 3 - hash under diff project
        switch exi
            case {0,3}
                imapCommon.add_alias_DB(obj.database, mod, hash, obj.alias);
                % 3 is ok, different projects can use same info
            case 1
                % do nothing
            case 2
                obj.handle_alias_conflict(mod,hash);
        end

        imapCommon.update_aliases_FILE(obj.database,mod,hash);
    end
    function obj=handle_alias_conflict(obj,mod,hash)
        switch mod
            case {'pch','dsp','sel','dmp_pch','dmp_dsp'}
                str='Patches';
            otherwise
                str='Maps';
        end

        options={'Remove old?'; 'Ignore old?'; 'Adopt old?'};
        hashOld=imapCommon.alias2hash(obj.alias, mod);

        if obj.bDoForAll==1
            ind=obj.DoForAll;
        else
            disp([str ' already exists for ' obj.database ' ' mod ' alias ' obj.alias '.'])
            disp(['    NEW: ' hash]);
            disp(['    OLD: ' hashOld]);
            disp(['    Would you like to...'])
            [out,ind,obj.exitflag]=basicSelect(options);
            %ind = 3; % XXX
        end

        if obj.bDoForAll==-1
            obj.bDoForAll=basicYN('Do this for all modules if there is a conflict?');
            %obj.bDoForAll=3; % XXX
        end


        if obj.exitflag==1;
            return
        elseif ind == 1
            imapCommon.rm_files(    obj.database, mod, hashOld);
            imapCommon.rm_alias_DB( obj.database, mod, hashOld, obj.alias);
            imapCommon.add_alias_DB(obj.database, mod, hash,    obj.alias);
        elseif ind == 2
            imapCommon.add_alias_DB(obj.database, mod, hash,    obj.alias);
        elseif ind == 3
            obj.bAdopted=1;
            str=['Adopting mods:' newline];
            [bSameProps,bSameOpts,bSameHashes]=imapCommon.check_def_compat(obj.database, mod, hashOld, obj.database, mod, hash);
            if ~bSameProps
                str=[str '  Properties are different' newline];
            elseif bSameOpts
                str=[str '  Options are different' newline];
            elseif bSameProps
                str=[str '  Hashes are different' newline];
            end

            if ~bSameProps || ~bSameOpts || ~bSameHashes
                disp(str);
                out=basicYN(['    Is this OK?']);
                if out==0
                    obj.exitflag=1;
                    return
                end
            end


            direOld=imapCommon.get_directory_f(obj.database,mod,hashOld);

            if ~isempty(hashOld) && exist(direOld,'dir')
                imapCommon.mv_files(    obj.database, mod, hashOld, obj.database, mod, hash);
            end
            imapCommon.add_alias_DB(obj.database, mod, hash,    obj.alias);
            imapCommon.rm_alias_DB( obj.database, mod, hashOld, obj.alias);
            obj.init_mod(mod,1);
        end
     end
end

methods(Hidden=true)
    function obj=vet(obj)
        % no deps
        obj.MODS.vet=imapVet(obj.database, obj.Opts.vet, obj.plotOpts.vet,0);
        obj.hashes.vet=obj.MODS.vet.hash;

    end
    function obj=gen(obj)
        % no deps
        obj.MODS.gen=imapGen(obj.database, obj.Opts.gen, obj.plotOpts.gen,0);
        obj.hashes.gen=obj.MODS.gen.hash;

    end
    function obj=bin(obj)
        obj.get_bin_params();
        obj.MODS.bin=imapBin(obj.database, obj.imgTypes.bin{1}, obj.imgNames.bin{1}, obj.imgNames.bin{2},obj.Opts.bin, obj.plotOpts.bin, 0);


        % NOTE
        obj.bStopAtSmp=obj.MODS.bin.bGetEdges;
    end
    function obj=smp(obj)
        obj.get_smp_params();
        obj.MODS.smp=imapSmp(obj.database, obj.imgTypes.smp,  obj.hashes.bin, obj.Opts.smp, obj.plotOpts.smp, 0);

    end
    function obj=pch(obj)
        obj.get_pch_params();
        obj.MODS.pch=imapPch(obj.database, ...
                             obj.imgTypes.pch, ...
                             obj.imgNames.pch, ...
                             obj.Opts.pch, ...
                             obj.plotOpts.pch, ...
                             0);
        obj.hashes.dmp_pch=obj.hashes.pch;


    end
    function obj=dsp(obj)
        obj.get_dsp_params();
        obj.MODS.dsp=imapDSP(obj.hashes, ...
                             obj.Opts.dsp, ...
                             obj.plotOpts.dsp, ...
                             0);
        obj.hashes.dmp_dsp=obj.hashes.pch;
    end
    function obj=sel(obj)
        obj.get_sel_params();
        obj.MODS.sel=imapSel(obj.Opts.sel.hashes, ...
                             obj.imgTypes.sel, ...
                             obj.imgNames.sel, ...
                             obj.Opts.sel, ...
                             obj.plotOpts.sel, ...
                             0);
    end
%%
    function obj=dmp_pch(obj)
        obj.get_dmp_pch_params();
        obj.MODS.dmp_pch=imapDmp(obj.Opts.dmp_pch.hashes, ...
                             obj.imgTypes.dmp_pch, ...
                             obj.imgNames.dmp_pch, ...
                             obj.plotOpts.dmp_pch, ...
                             0);
    end
    function obj=dmp_dsp(obj)
        obj.get_dmp_dsp_params();
        obj.MODS.dmp_dsp=imapDmp(obj.Opts.dmp_dsp.hashes, ...
                                 obj.imgTypes.dmp_dsp, ...
                                 obj.imgNames.dmp_dsp, ...
                                 obj.plotOpts.dmp_dsp, ...
                                 0);
    end
end
end
