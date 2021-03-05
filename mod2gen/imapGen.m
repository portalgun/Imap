classdef imapGen < handle & imapCommon & LR & imapGen_main & imapGen_modules & imapGen_plot & imapGen_util
% XXX correlation
properties
    imgType
    imgName

    %OPTS
    mapsNeeded=cell(0)

    genOpts %< imapGenModules
        %type
        %typeL
        %typeLminMax
        % nL % NOT INPUT
        % wk etc
end
properties(Hidden = true)
    gen
    im

    I
    k

    db

    %nImg
    %nLandR

    %IszRC

    %LandR
    %notLandR
    %LorR
    %notLorR

    blankmap

    TYPE='gen'
end
methods
    function obj = imapGen(database,Opts,plotOpts,bRun)
        obj.database=database;
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        if ~exist('plotOpts','var') || isempty(plotOpts)
            plotOpts=struct();
        end
        if ~exist('bRun','var') || isempty(bRun)
            bRun=0;
        end

        obj=obj.parse_Opts(Opts);
        obj.get_img_db_info();
        obj.parse_plotOpts_p(plotOpts);
        obj.get_hash();
        obj.save_def();
        if bRun
            obj.main();
        end
    end
    function obj=parse_Opts(obj,Opts)
        genOpts=struct();
        [P,typeP,typeLP]=imapGen.get_parse();

        % Split
        typeOpts=Opts.type;
        Opts=rmfield(Opts,'type');
        if isfield(Opts,'typeL')
            typeLopts=Opts.typeL;
            Opts=rmfield(Opts,'typeL');
        else
            typeLopts=cell(0);
        end
        [Opts,Other]=structSplit(Opts,P(:,1));

        % PARSE OPTS
        obj=parse(obj,Opts,P);

        % PARSE TYPE
        [typeOpts,obj.mapsNeeded]=parse_fun(typeOpts,typeP,obj.mapsNeeded);
        obj.genOpts.type=typeOpts;


        % PARSE TYPE L
        if isstruct(typeLopts)
            typeLopts={typeLopts};
        elseif ~isempty(typeLopts) & ~iscellstruct(typeLopts)
            error('typeL is not empty, a cell struct, or a struct.')
        end
        if ~isempty(typeLopts)
            for i = 1:length(typeLopts)
                [typeLopts{i},obj.mapsNeeded]=parse_fun(typeLopts{i},typeLP,obj.mapsNeeded);
            end
            obj.genOpts.typeL=typeLopts;
        end
        obj.genOpts.nL=length(typeLopts);


        %% OTHER
        flds=fieldnames(Other);
        for i = 1:length(flds)
            fld=flds{i};
            genOpts.(fld)=Other.(fld);
        end

        obj.parse_LorRorB();

        function [opts,mapsNeeded]=parse_fun(opts,Parse,mapsNeeded)
            opts=parse([],opts,Parse);

            % CHECK IF NAME EXISTS AS METHOD
            if ~startsWith(opts.name,'X_')
                opts.name=['X_' opts.name];
            end
            if ~ismethod('imapGen_modules',opts.name)
                error([opts.name ' is not a imapGen method']);
            end

            % GET REQUIRED PARAMS
            params=imapGen.get_module_params(opts.name);
            opts.maps=params.maps;
            opts.objParams=params.objParams;
            opts.dbParams=params.dbParams;
            opts.bLorR=params.bLorR;
            fldsP=params.setParams;


            if isfield(params,'bRmBorder')
                opts.bRmBorder=params.bRmBorder;
            else
                opts.bRmBorder=0;
            end
            if isfield(params,'borderMult')
                opts.borderMult=params.borderMult;
            else
                opts.bRmBorder=.5;
            end

            % GET LIST OF USER SET PARAMS
            fldsO=fieldnames(opts.setParams);

            % MISSING REQUIRED PARAMS
            indw=find(~ismember(fldsO,params.setParams));
            if ~isempty(indw)
                warstr=['The following parameters are present, but not required by ' opts.name ':' newline joinSane(fldsO(indw),newline) newline newline];
            end

            % EXTRA/MISNAMED PARAMS
            inde=find(~ismember(params.setParams,fldsO));
            if ~isempty(inde)
                errstr=['The following parameters are not present, but required by ' opts.name ':' newline joinSane(fldsP(inde),newline) newline newline];
                if ~isempty(indw)
                    errstr=[errstr warstr];
                end
                error(errstr);
            elseif ~isempty(indw)
                warning(warstr);
            end

            % ADD MAPS NEEDED
            if isfield(opts,'maps')
                mapsNeeded=union(mapsNeeded,opts.maps);
            end
        end

    end

end
methods(Static=true)
    function [P,typeP,typeLP]=get_parse()
        P={ 'LorRorB', 'B', 'isLorRorB' ...
           ;'imgNums', []  'isallint'...
        };
        typeP={ ...
            'name',[],'ischar'...
            ;'setParams',struct(),'isstruct'...
        };
        typeLP={ ...
            'name',[],'ischar_e'...
            ;'setParams',struct(),'isstruct' ...
            ;'minMax',[-inf inf],'isallnum2_e' ...
        };
    end
    function params=get_module_params(name)
        if startsWith(name,'X_')
            name=name(3:end);
        end
        str=['imapGen_modules.params_' name  ';'];
        params=eval(str);
    end
end
end
