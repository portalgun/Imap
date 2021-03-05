classdef imapDmp
properties
    hashes
    imgType
    imgName

    PTCHS
end
methods
    function obj=imapDmp(hashes,imgType,imgName,plotOpts,bRun)
        obj.hashes=hashes;
        obj.imgType=imgType;
        obj.imgName=imgName;
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        if ~exist('plotOpts','var') || isempty(plotOpts)
            plotOpts=struct();
        end
        if ~exist('bRun','var') || isempty(bRun)
            bRun=1;
        end

        %obj=obj.parse_Opts(Opts);

        % HASHES
        %obj.hashes.dmp=obj.hash;
        if strcmp(obj.imgType,'dsp')
            obj.hashes.dsp=obj.imgName;
        elseif strcmp(obj.imgType,'pch')
            obj.hashes.pch=obj.imgName;
        end

        %obj.parse_plotOpts_p();
        %obj.save_def();

        if bRun
            obj.main()
        end
    end
    function obj=parse_Opts(obj,Opts)
        if isfield(Opts,'imgNums')
            Opts=rmfield(Opts,'imgNums');
        end
        if isfield(Opts,'LorRorB')
            Opts=rmfield(Opts,'LorRorB');
        end
        if isfield(Opts,'hashes')
            if isempty(obj.hashes)
                obj.hashes=Opts.hashes;
            end
            Opts=rmfield(Opts,'hashes');
        end

        P=imapDmp.get_parseOpts();
        obj=parse(obj,Opts,P);

    end
    function obj=run(obj)
        obj.main();
    end
%end
%methods(Access=protected)
    function obj=main(obj)
        [srcTable,srcKey]=obj.get_src_table();
        obj.PTCHS=ptchs([],obj.hashes, srcTable, srcKey);
        obj.PTCHS.save();
    end
    function [srcTable,srcKey]=get_src_table(obj)
        %srcKey={'P','fname','I','K','B','S','PctrRC','binVal','val'}
        if strcmp(obj.imgType,'pch')
            [srcTable, srcKey]=imapPch_Tsrc.load_src_table(obj.hashes.database,obj.hashes.pch);
        elseif strcmp(obj.imgType,'dsp')
            [srcTable, srcKey]=imapDsp_Tsrc.load_src_table(obj.hashes.database,obj.hashes.dsp);
        end
    end
end
methods(Static=true)
    function P=get_parseOpts();
        %P={...
        %     %'dmpName', [],'ischar_e'...
        %  };
    end
end
end
