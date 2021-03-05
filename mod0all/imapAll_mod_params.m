classdef imapAll_mod_params < handle
methods(Access=?imapAll_mod_init)
    function obj=get_hash_table(obj,module)
        h=obj.hashes;
        h.database=obj.database;
        if strcmp(module,'smp')
            h=rmfield(h,'pch');
            h=rmfield(h,'dmp_pch');
            h=rmfield(h,'dsp');
            h=rmfield(h,'dmp_dsp');
            h=rmfield(h,'sel');
        elseif strcmp(module,'pch')
            h=rmfield(h,'dmp_pch');
            h=rmfield(h,'dsp');
            h=rmfield(h,'dmp_dsp');
            h=rmfield(h,'sel');
        elseif strcmp(module,'dmp_pch')
            h=rmfield(h,'dsp');
            h=rmfield(h,'dmp_dsp');
            h=rmfield(h,'sel');
        elseif strcmpWith(module,'dsp')
            h=rmfield(h,'sel');
        elseif strcmpWith(module,'dmp_dsp')
            h=rmfield(h,'sel');
        end
        obj.Opts.(module).hashes=h;
    end
    function obj=get_bin_params(obj)
        % TODO OTHER CASES
        % - no gen?
        obj.imgTypes.bin{1}='gen';
        obj.imgTypes.bin{2}='vet';

        obj.imgNames.bin{1}=obj.hashes.gen;
        obj.imgNames.bin{2}=obj.hashes.vet;
    end
    function obj=get_smp_params(obj)
        obj.imgTypes.smp='bin';
        obj.imgNames.smp=obj.hashes.bin;

        obj.get_hash_table('smp');
    end
    function obj=get_pch_params(obj)
        obj.imgTypes.pch='smp';
        obj.imgNames.pch=obj.hashes.smp;

        obj.get_hash_table('pch');
    end
    function obj=get_dsp_params(obj)
        obj.imgTypes.dsp='pch';
        obj.imgNames.dsp=obj.hashes.pch;

        obj.get_hash_table('dsp');
    end
    function obj=get_sel_params(obj)
        if isfield(obj.hashes,'dsp') && ~isempty(obj.hashes.dsp)
            obj.imgTypes.sel='dsp';
            obj.imgNames.sel=obj.hashes.dsp;
        else
            obj.imgTypes.sel='pch';
            obj.imgNames.sel=obj.hashes.pch;
        end

        obj.get_hash_table('sel');
    end
%%
    function obj=get_dmp_pch_params(obj)
        obj.imgTypes.dmp_pch='pch';
        obj.imgNames.dmp_pch=obj.hashes.pch;
        obj.get_hash_table('dmp_pch');
    end
    function obj=get_dmp_dsp_params(obj)
        obj.imgTypes.dmp_dsp='dsp';
        obj.imgNames.dmp_dsp=obj.hashes.dsp;
        obj.get_hash_table('dmp_dsp');
    end
end
end
