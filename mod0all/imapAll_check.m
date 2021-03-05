classdef imapAll_check < handle

methods(Access=?imapAll_mode)
    function obj=check_all(obj)
        obj.missingFiles=cell(length(obj.modules),1);
        for i = 1:length(obj.modules)
            if obj.runCodes(i)==0
                continue
            elseif obj.bStopAtSmp && strcmp(obj.modules{i},'smp')
                return
            end
            obj.check_completion(obj.modules{i});
        end
    end
    function obj=check_completion(obj, module)
        % COMPLETION CODES
        % 0 not
        % 1 initialized
        % 2 progress
        % 3 complete

        ind=obj.get_module_ind(module);

        if strcmp(module,'dsp'); obj.completion(ind)=1; return; end  % XXX
        if strcmp(module,'pch'); obj.completion(ind)=0; return; end  % XXX

        hash=obj.hashes.(module);

        imgNums=[];
        if isfield(obj.Opts.(module),'imgNums')
            imgNums=obj.Opts.(module).imgNums;
        else
            imgNums=obj.Opts.pch.imgNums;
        end

        obj.missingFiles{ind}=imapCommon.get_missing_files_f(imgNums, obj.database, module, hash);

        bSingle=ismember(module,{'dmp_pch','dmp_dsp','sel'});
        if strcmp(module,'dsp')
            if cellfun(@isempty,obj.missingFiles{ind})
                obj.completion(ind)=3;
            elseif cellfun(@(x) numel(imgNums)==numel(x),obj.missingFiles{ind})
                obj.completion(ind)=1;
            else
                obj.completion(ind)=2;
            end
        elseif strcmp(module,'pch') && numel(imgNums)==numel(obj.missingFiles{ind})
            obj.completion(ind)=1;
        elseif bSingle && numel(obj.missingFiles{ind})==1
            obj.completion(ind)=1;
        elseif ~bSingle & numel(imgNums)==numel(obj.missingFiles{ind})*2
            obj.completion(ind)=1;
        elseif isempty(obj.missingFiles{ind})
            obj.completion(ind)=3;
        else
            obj.completion(ind)=1;
        end
    end

end
end
