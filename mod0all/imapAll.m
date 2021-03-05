classdef imapAll < handle & imapAll_check & imapAll_main & imapAll_mod_init & imapAll_mod_params & imapAll_mode & imapAll_util & imapCommon_plot
% XXX imapCommon needed?
% class obj=imapFull(defName,mode)
%vet,gen,bin,smp,pch,dsp,sel
%1  ,2  ,3  ,4  ,5  ,6  ,7 .8
% RUN CODES
% 0 skip
% 3 skip no prompt
% 1 continue
% 4 continue no prompt
% 2 rerun/run all
properties
    defName

    % base
    alias
    imgNums
    LorRorB
    database
    mods
    mode

    MODS=struct();

    Opts=struct();
    % all %% NOTE
    % vet
    % gen
    % bin
    % smp
    % crp
    % sel

    plotOpts=struct();
    % vet
    % gen
    % bin
    % smp
    % pch
    % dsp
    % sel

    hashes=struct();
    %
    imgTypes=struct();
    % ...
    imgNames=struct();
    % ...

    bInit=struct();
    bComplete=struct();


    missingFiles
end
properties(Hidden=true)
    completion
    runCodes=ones(8,1)*-1;

    modules
    bStopAtSmp=0
    OrigHash
    OrigOpts
    OrigPlotOpts

    bDoForAll=-1;
    DoForAll=-1;
    bAdopted=0;

    exitflag=0;

end
methods
    function obj=imapAll(defName,mods,mode)
        obj.modules=imapCommon.modules;

        if ~startsWith(defName,'D_imap_')
            defName=['D_imap_' defName];
        end
        fname=which(defName);

        if isempty(fname)
            error('Cant find file from defName');
        end
        obj.defName=defName;
        if exist('mods','var') && ~isempty(mods)
            obj.mods=mods;
        end
        if exist('mode','var') && ~isempty(mode)
            obj.mode=mode;
        end


        obj.init();
        if obj.exitflag==1; return; end
        %obj.run();
    end
end
methods(Access=protected)
    function obj=init(obj)
        obj.get_Opts();

        obj.init_mods();        %imapAll_mod_init % XXX hash
        if obj.exitflag==1; return; end

        obj.check_all();        %get_run_codes
        obj.mode_selector();    %convert runCodes

        %obj.get_hash();         %imapAll_util
        %obj.save(); XXX bottlneck %imapAll_util
    end
    function obj=get_Opts(obj)
        obj.read_Opts();
        obj.move_Opts();
        obj.parse_base();
        obj.apply_base_to_mods();

        obj.parse_plot_opts();
    end
    function obj=read_Opts(obj)
        run(obj.defName);
        if ~exist('Opts','var')
            Opts=struct();
        end
        obj.Opts=Opts;
        mods=[obj.modules, 'base'];
        for i = 1:length(mods)
            mod=mods{i};

            if exist(mod,'var')
                str=[ mod ';' ];
                obj.Opts.(mod)=eval(str);
            else
                obj.Opts.(mod)=struct();
            end
            if ~isfield(obj.Opts.(mod),'plotOpts')
                obj.Opts.(mod).plotOpts=struct();
            end
        end
    end
%% MOVE
    function obj=move_Opts(obj)
        % APPLY BASE
        obj.move_base();
        obj.move_plotOpts();

    end
    function obj=move_base(obj)
        % alias
        if isfield(obj.Opts.base,'alias')
            obj.alias=obj.Opts.base.alias;
            obj.Opts.alias=rmfield(obj.Opts.base,'alias');
        elseif ~isempty(obj.defName)
            obj.alias=sed('s',obj.defName,'^D_imap_','');
            obj.alias=sed('s',obj.alias,'\.m$','');

        end
        % ImgNums
        if isfield(obj.Opts.base,'imgNums')
            obj.imgNums=obj.Opts.base.imgNums;
            obj.Opts.base=rmfield(obj.Opts.base,'imgNums');
        end
        % LorRorB
        if isfield(obj.Opts.base,'LorRorB')
            obj.Opts.LorRorB=obj.Opts.base.LorRorB;
            obj.Opts.base=rmfield(obj.Opts.base,'LorRorB');
        end


        % mode
        if isfield(obj.Opts.base,'mode')
            if isempty(obj.mode)
                obj.mode=obj.Opts.base.mode;
            end
            obj.Opts.base=rmfield(obj.Opts.base,'mode');
        end

        if isfield(obj.Opts.base,'mods')
            if isempty(obj.mods)
                obj.mods=obj.Opts.base.mods;
            end
            obj.Opts.base=rmfield(obj.Opts.base,'mods');
        end

        % database
        if isfield(obj.Opts.base,'database')
            obj.database=obj.Opts.base.database;
            obj.Opts.base=rmfield(obj.Opts.base,'database');
        end
        if isfield(obj.Opts.base,'plotOpts')
            % XXX ?
            obj.Opts.base=rmfield(obj.Opts.base,'plotOpts');
        end

        flds=fieldnames(obj.Opts.base);
        if ~isempty(flds)
            flds=join(flds,newline)
            error(['Unrecognized base params: ' newline flds{i} ])
        end
    end
    function obj=move_plotOpts(obj)
        obj.plotOpts=struct();
        for i = 1:length(obj.modules)
            fld=obj.modules{i};
            obj.plotOpts.(fld)=obj.Opts.(fld).plotOpts;
            obj.Opts.(fld)=rmfield(obj.Opts.(fld),'plotOpts');
        end
    end
%%
    function obj=parse_plot_opts(obj)
        for i = 1:length(obj.modules)
            fld=obj.modules{i};
            if isfield(obj.plotOpts,fld)
                obj.plotOpts.(fld)=imapCommon_plot.parse_plotOpts(fld,obj.plotOpts.(fld),[]);
            else
                obj.plotOpts.(fld)=imapCommon_plot.parse_plotOpts(fld,[],[]);
            end
        end
    end
%%
    function obj=parse_base(obj)
        %Opts from database
        if ~isempty(obj.database)
            if isempty(obj.imgNums)

                db=dbInfo(obj.database);
                if isprop(db,'gdImages')
                    obj.imgNums=db.gdImages;
                elseif isprop(db,'allImages')
                    obj.imgNums=db.allImages;
                end
            end
       end
       if isempty(obj.LorRorB)
            obj.LorRorB='B';
       end
       if iscell(obj.mode)
           new=zeros(length(obj.modules));
           for i = 1:length(obj.mode)
               new(i)=new | ismember(obj.modules,obj.mode{1});
           end
           obj.mode=new;
       end
       if isempty(obj.mode) && ~isempty(obj.mods)
            n=length(obj.modules);
            obj.runCodes=zeros(n,1);
            obj.runCodes(ismember(1:n,obj.mods))=1;
            obj.mode='manual';
       elseif isnumeric(obj.mode) && all(isint(obj.mode)) && numel(obj.mode) <= numel(obj.modules)
           obj.runCodes=obj.mode;
           obj.mode='manual';
       elseif ischar(obj.mode) && ~ismember(obj.mode, {'skip','rerun','continue','prompt'})
           error(['Unrecognized mode: ' mode])
       elseif ~isempty(obj.mode)
           error(['Unrecognized mode'])
       else
            obj.runCodes=ones(n,1)*-1;
       end
    end
    function obj=apply_base_to_mods(obj)
        ptch={'pch','dmp_pch','dsp','dmp_dsp','sel'};
        noNums={'dmp_pch','dmp_dsp','dsp','sel'};
        for i = 1:length(obj.modules)
            mod=obj.modules{i};
            if ismember(mod,noNums)
                continue
            end

            if ~isfield(obj.Opts.(mod),'imgNums')  || isempty(obj.Opts.(mod).imgNums)
                obj.Opts.(mod).imgNums=obj.imgNums;
            end

            if ~isfield(obj.Opts.(mod),'LorRorB')  || isempty(obj.Opts.(mod).LorRorB)
                obj.Opts.(mod).LorRorB=obj.LorRorB;
            end

        end
    end

    %function obj=update_imgNums(obj,module)
    %    % XXX
    %    obj.Opts.
    %    if obj.runCodes==1
    %        obj.update_imgNums(obj.modules{i});
    %    end

    %    ind=get_module_ind(module);
    %    obj.MODS.(module).imgNums=obj.missinFiles;
    %end

end
end
