classdef imapCommon_plot < handle
methods
    function obj=parse_plotOpts_p(obj,plotOpts,newParse)
        if ~exist('plotOpts','var')
            plotOpts=[];
        end
        if ~exist('newParse','var')
            newParse=[];
        end

        obj.plotOpts=imapCommon.parse_plotOpts(class(obj),plotOpts,newParse);
    end
    function [obj,f]=fig_fun(obj,name)
        new=nFn;
        if ~isfield(obj.plotOpts,'f')
            obj.plotOpts.f=struct();
        end
        % INVISIBLE PROG
        if ~obj.plotOpts.bProg && strcmp(name,'prog') &&  obj.bSaveProg
            obj.plotOpts.savef.(name) = figure('visible','off');
        % NEW FIG NUM
        elseif ~obj.is_val_plot_fld('f',name) || new <= obj.plotOpts.f.(name);
            obj.plotOpts.f.(name)=new;
        % otherwise Existing Fig num implicit
        end

        % EXISTING FIGURE NUMBER
        if new <= obj.plotOpts.f.(name) && new==1
            obj.plotOpts.savef.(name)=figure(obj.plotOpts.f.(name));
        else
            try
                set(0,'CurrentFigure',obj.plotOpts.f.(name));
                obj.plotOpts.savef.(name)=gcf;

            catch
                obj.plotOpts.savef.(name)=figure(obj.plotOpts.f.(name));
            end
        end
    end

    function obj=sg_fun(obj,name,titl)
        if ~isfield(obj.plotOpts,'sg')
            obj.plotOpts.sg=struct();
        end
        if obj.is_val_plot_fld('sg',name)
            obj.plotOpts.sg.(name).String=titl;
        else
            obj.plotOpts.sg.(name)=sgtitle(titl);
            obj.plotOpts.sg.(name).FontSize=18;
        end
    end
    function obj=pos_fun(obj,name,XY,WH)
        %% CURRENT
        if obj.is_val_plot_fld('XY',name) || obj.is_val_plot_fld('WH',name)
            p=get(gcf,'Position');
            if ~exist('XY','var') || isempty(XY)
                XYc=p(1:2);
            end
            if ~exist('WH','var') || isempty(WH)
                WHc=p(1:2);
            end
        end
        if (~exist('XY','var') || isempty(XY)) && exist('XYc','var') && ~isempty(XYc)
            XY=XYc;
        elseif (~exist('XY','var') || isempty(XY))
            XY=[0 0];
        end
        if (~exist('WH','var') || isempty(WH)) && exist('WHc','var') && ~isempty(WHc)
            WH=WHc;
        elseif (~exist('WH','var') || isempty(WH))
            error('TODO');
        end
        if ~obj.is_val_plot_fld('WH',name)
            obj.plotOpts.WH.(name)=WH;
        end
        if ~obj.is_val_plot_fld('XY',name)
            obj.plotOpts.pos.(name)='XY';
        end
        set(gcf,'Position',[XY(1) XY(2) WH(1) WH(2)]);
    end
    function out=is_val_plot_fld(obj,prp,name)
        out=isfield(obj.plotOpts.(prp),name) && ~isempty(obj.plotOpts.(prp).(name)) && ...
            (~isobject(obj.plotOpts.(prp).(name)) || isvalid(obj.plotOpts.(prp).(name)));
    end
%% PHT
    function []=plot_pht_p(obj)
        imagesc(obj.plotOpts.phtFull);
        formatImage();
        hold off
    end
    function obj=get_pht(obj,I)
        if ~exist('I','var') || isempty(I)
            I=obj.I;
        end
        pht=getImg(obj.database,'img','pht',I);
        obj.plotOpts.phtFull=[pht{1} pht{2}].^.4;
        obj.plotOpts.pht=pht;
        %imagesc(obj.plotOpts.phtFull)
    end
%% SAVE
    function []=save_prog(obj)
        obj.save_fig('prog','fig');
    end
    function []=save_fig(obj,fldName,figType,I,k,h)
        if ~exist('I','var') || isempty(I)
            I=obj.I;
        end
        if ~exist('k','var') || isempty(k)
            k=obj.k;
        end

        if ~exist('figType','var'); figType=[]; end
        type=obj.get_type();
        fname=imapCommon_plot.get_fig_fname_f(obj.database,type,obj.hash,I,k,figType);
        fig=obj.plotOpts.savef.(fldName);

        set(fig, 'InvertHardcopy', 'off')
        saveas(fig.Number,fname,'png');
        %imwrite(fig,[fname '.png']);
    end
end
methods(Static=true)
    function plotOpts=parse_plotOpts(module,plotOpts,newParse);
        if ~exist('newParse','var')
            newParse=[];
        end
        if ~startsWith(module,'imap')
            module=['imap' makeUpperCase(module(1)) module(2:end)];
        end

        % BASIC PARSE
        P=imapCommon_plot.get_plot_ParseOpts();

        % INTERNAL PARSE
        P=[P; imapCommon_plot.get_plot_ParseOpts_extra()];

        % MODULE SPECIFIC PARSE
        if ismethod(module,'get_parse_plot')
            P=[P; eval([module '.get_parse_plot;'])];
        end

        % CHANGE SPECIFIC DEFAULTS
        if strcmp(module,'imapBin') || strcmp(module,'imapSmp')
            ind=find(ismember(P(:,1),'bSaveProg'));
            P{ind,2}=1;
        end
        if strcmp(module,'imapPch') || strcmp(module,'imapDsp') || strcmp(module,'imapSel')
            ind=find(ismember(P(:,1),'bProg'));
            P{ind,2}=0;
        end

        % OTHER PARSE
        P=[P; newParse];

        %PARSE
        plotOpts=parse([],plotOpts,P);

        % INIT CMAPS
        if ~isempty(plotOpts.cmap1) && ischar(plotOpts.cmap1)
            plotOpts.cmap1=cmap(plotOpts.cmap1);
        end
        if ~isempty(plotOpts.cmap2) && ischar(plotOpts.cmap1)
            plotOpts.cmap2=cmap(plotOpts.cmap2);
        elseif ischar(plotOpts.cmap1)
            plotOpts.cmap2=invertRGB(plotOpts.cmap1);
        end

    end
    function P=get_plot_ParseOpts()
        P     ={'bWait',     0,'isbinary'....
               ;'bProg', 1,'isbinary'....
               ;'bSaveProg', 0,'isbinary'....
               ;'cmap1',  'summer', @(x) ischar(x) || isa(x,'cmap')...  % XXX
               ;'cmap2',  [], @(x) isempty(x) || ischar(x) || isa(x,'cmap')...
               };
    end
    function fname=get_fig_fname_f(database,type,hash,I,k,figType)
        if k==1
            LR='L';
        elseif k==2
            LR='R';
        elseif k==3
            LR='B';
        elseif k==4
            LR='I';
        else
            LR='A';
        end
        if ~exist('figType','var'); figType=[]; end
        dire=imapCommon.get_fig_dir_f(database,type,hash,figType);
        name=[LR num2str(I,'%04i')];
        fname=[dire name];
    end
    function dire=get_fig_dir_f(database,type,hash,figType)
        if ~exist('figType','var'); figType='fig'; end
        dire=imapCommon.get_directory_f(database,type,hash);
        dire=[dire und figType und filesep];
        if ~exist(dire,'dir')
            mkdir(dire);
        end
    end
end
methods(Static=true, Access=protected)
    function P=get_plot_ParseOpts_extra()
        P   = {...
                  'pht',struct(),'isstruct'...
                  ;'phtFull',struct(),'isstruct'...
                  ;'f',struct(),'isstruct'...
                  ;'sg',struct(),'isstruct'...
                  ;'WH',struct(),'isstruct'...
                  ;'XY',struct(),'isstruct'...
                  ;'savef',struct(),'isstruct'...
              };
    end
end
end
