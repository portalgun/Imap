classdef imapDsp < handle & imapDsp_inds & imapDsp_main & imapDsp_Tind & imapDsp_Ttable & imapDsp_util
% XXX cross unique rows
% XXX hashInd Table
% XXX long to short name
% XXX pr
% XXX progress plots
% XXX check continue
% XXX rm fname, I, D, from selkey -> src table
properties
    display
    subjInfo
    winInfo
    trgtInfo
    focInfo
    wdwInfo

    lvlCross
        % oneTOone
        % full
    hashes
end
properties(Hidden=true)
    ptch

    table
    key

    flds={'display','subjInfo','winInfo','trgtInfo','focInfo','wdwInfo'}

    nPtch
    N

    udisplays
    udisplaynames

    indOpts
    indOptsAll
    indHash
    indHashesAll
    indDirAll

end
methods

    function obj=imapDsp(hashes,Opts,plotOpts,bRun)
        i=1
        i=2
        obj.hashes=hashes;
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        if ~exist('plotOpts','var') || isempty(plotOpts)
            plotOpts=struct();
        end
        if ~exist('bRun','var') || isempty(bRun)
            bRun=1;
        end

        obj=obj.parse_Opts(Opts);
        obj.get_hash();
        obj.parse_plotOpts_p(plotOpts);
        obj.save_def();
        disp();

        if bRun
            obj.main();
        end
    end

%% PARSE
    function obj=parse_Opts(opts)
        P=imapDsp.get_parse();
        obj=parse(obj,opts,P);
        if nflds(obj.subjInfo)==0
            obj.subjInfo.IPDm=0.065;
            obj.subjInfo.LExyz=[-0.065/2, 0, 0];
            obj.subjInfo.RExyz=[-0.065/2, 0, 0];
        end
        % XXX parse infos through ptch

        obj.cleanup_info();
        obj.expand_info();
        obj.get_displays(); %
    end
    function obj=cleanup_info(obj)
        flds=obj.flds;
        % rm empty
        for i = 1:length(flds)
            fld=flds{i};
            flds2=fieldnames(obj.(fld));
            for j = 1:length(flds2)
                fld2=flds2{j};
                if isempty(obj.(fld).(fld2))
                    obj.(fld)=rmfield(obj.(fld),fld2);

                end
            end
        end
    end
%%
    function obj=expand_info(obj)

        % small expand & counts
        counts=cell(length(flds),1);
        for i = 1:length(flds)
            fld=flds{i};
            [obj.(fld),counts{i}]=count_fun(obj.(fld));
        end
        allcounts=vertcat(counts{:});
        if strcmp(obj.cross,'oneTOone') && any(~ismember(allcounts,[N; 1]))
            error('incompatible fields for 1to1');
        elseif strcmp(obj.cross,'oneTOone')
            obj.N=max(allcounts,'all');
            return
        elseif strcmp(obj.cross,'full')
            N=prod(allcounts,'all');
            reps=rep_count_fun(reps);
        end
        obj.N=N;

        i=0;
        for f1 = 1:length(flds);
            fld=flds{f1};
            flds2=fieldnames(obj.(fld));
            for f2 = 1:length(flds2)
                i=i+1;
                fld2=flds{2};
                val=obj.(fld).(fld2);

                % NOTE, single row fields are not expanded
                if counts(i)==1
                    continue
                end

                obj.(fld).(fld2)=rep_fun(N, val, reps(i,:));
            end
        end

        % large expand
        function out=rep_fun(N,val,reps)
            out=repmat(repelem(val,reps(1),1) , reps(2),1);
            assert(size(out,1)==N);
        end
        function reps=rep_count_fun(allcounts)
            k=size(allcounts,1);
            reps=zeros(k,2);

            for i = 1:k
                reps(i,1)=prod(allcounts(i+1:end));
                reps(i,2)=prod(allcounts(1:i-1));
            end

        end

        function [F,counts]=count_fun(F)
            flds=fieldnames(F);
            counts=zeros(numel(flds),1);
            for i = 1:length(flds)
                fld=flds{i};
                n=size(F.(fld),1);
                if strcmp(fld,'dispORwin') && ischar(F.(fld))
                    counts(i)=1;
                    F.(fld)={F.(fld)};
                elseif ~strcmp(fld,'dispORwin') && size(F.(fld),1) == 1 && size(F.(fld),2) > 2
                    F.(fld)=transpose(F.(fld));
                    if regExp(fld,'(XYZ|xyz)')
                        m=3;
                    else
                        m=2;
                    end
                    F.(fld)=[F.(fld) zeros(n,m)];
                    counts(i)=n;
                else
                    counts(i)=n;
                end
            end
        end
    end
    function obj=get_displays(obj)
        obj.udisplays=unique(obj.display);
        obj.udisplaynames=cell(numel(obj.udisplays),1);
        for i = 1:length(obj.udisplays)
            d=obj.udisplays{i};
            if isa(d,'DISPLAY')
                obj.udisplaynames{i}=DISPLAY.get_name_from_display(d);
            elseif ~isempty(d) || ~ischar(obj.display)
                error('invalid display');
            else
                obj.udisplaynames{i}=d;
                obj.udisplays{i}=DISPLAY.get_display_from_string(d);
            end
        end
    end
end
methods(Static=true)
    function P=get_parse()
        P={'display',[],'ischar' ...
          ;'subjInfo',struct(),'isstruct' ...
          ;'winInfo',[],'isstruct' ...
          ;'trgtInfo',[],'isstruct' ...
          ;'focInfo',[],'isstruct' ...
          ;'wdwInfo',struct(),'isstruct' ...
          };
    end
end
end
