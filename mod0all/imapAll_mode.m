classdef imapAll_mode < handle
methods(Access=protected)
    % GET RUN BGCODE FOR MODULE
    %
    % RUN CODES
    % -1 -
    %  0 skip
    %  1 continue
    %  2 rerun/run all
    %  3 prompt
    %
    % COMPLETION CODES
    % 0 not
    % 1 initialized
    % 2 progress
    % 3 complete

    function obj=mode_selector(obj)
        codes=ones(length(obj.modules),1)*-1;
        switch obj.mode
            case 'manual'
                return
            case 'rerun'
                ccodes(obj.completion<=3)=2;
            case 'skip'
                codes(obj.completion<3)=1;
                codes(obj.completion==3)=0;
            case 'continue'
                codes(obj.completion<=3)=1;
            case 'prompt'
                codes(obj.completion<=1)=1;
                codes(obj.completion>2)=4;

                obj.runCodes=codes;
                obj.prompt();
                return
        end
        obj.runCodes=codes;
    end
%% PROMPT
    function obj=prompt(obj)
        for i = 1:length(obj.modules)
            if  obj.runCodes(i)==3
                obj.prompt_action(obj.modules{i});
            end
        end
    end
    function obj=prompt_action(obj,module)
        ind=obj.get_module_ind(module);
        hash=obj.MODS.(module).hash;
        if obj.completion(ind)==3
            response=basicYN(['Database for ' module ' with hash ' hash ' appears complete. Rerun? (Y,N)']);
            if response==1
                obj.runCodes(ind)=2;
            elseif response==1
                obj.runCodes(ind)=0;
            end
        elseif obj.runCodes(ind)==2
            response=basicChar({'c','r','m'},['Database for ' module ' with hash ' hash ' appears have been started.' newline ...
                                              '(c)ontinue, (r)estart, or (s)kip?']);
            if response=='c'
                obj.runCodes(ind)=1;
            elseif response=='r'
                obj.runCodes(ind)=2;
            elseif response=='s'
                obj.runCodes(ind)=0;
            end
        end
    end
end
end
