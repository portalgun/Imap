classdef imapCommon_alias < handle
methods(Static=true)
    function [hashes,databases,types]=alias2hash(alias,mod)
        if ~imapCommon.exist_alias_fname_DB()
            hash='';
            database='';
            mod='';
            return
        end
        alias=sed('s',alias,'\.m$','');

        [aliases,hashes,databases,types]=imapCommon.load_alias_DB_parts();

        ind=ismember(aliases,alias);
        databases=databases(ind);
        types=types(ind);
        hashes=hashes(ind);

        if exist('mod','var') && ~isempty(mod)
            ind=find(ismember(types,mod));
            if isempty(ind)
                databases=[];
                mod=[];
                hashes=[];
                return
            elseif numel(ind)==1
                databases=databases{ind};
                types=types{ind};
                hashes=hashes{ind};
            else
                databases=databases(ind);
                types=types(ind);
                hashes=hashes(ind);
            end

       end
    end
    function [alias,database,type]=hash2alias(hash)
        if ~imapCommon.exist_alias_fname_DB()
            alias='';
            return
        end

        [aliases,hashes,databases,types]=imapCommon.load_alias_DB_parts();

        ind=ismember(hashes,hash);
        alias=aliases(ind);

        type=types(ind);
        database=databases(ind);
    end
    function print_aliases()
        [aliases,hashes,databases,types]=imapCommon.load_alias_DB_parts();

        [udb,~,udbinds]=unique(databases);

        for i = 1:length(udb)
            udbind=udbinds==i;
            db_fun(udb{i}, aliases(udbind), hashes(udbind), types(udbind));
        end
        function db_fun(db,aliases,hashes,types)
            display(['' db]);
            [ua,~,uainds]=unique(aliases);
            for i = 1:length(ua)
                uaind=uainds==i;
                alias_fun(db, ua{i}, hashes(uaind), types(uaind));
            end
        end
        function alias_fun(db,alias,hashes,types)
            display(['    ' alias]);
            flds={'vet','gen','bin','smp','pch','dsp','sel'};
            for i = 1:length(flds)
                fld=flds{i};
                str=['        ' fld];
                ind=find(ismember(types,fld));
                if ~isempty(ind)
                    for ii = 1:length(ind)
                        I=ind(ii);
                        str=[str ' ' hashes{I}];
                    end
                end
                disp(str);
            end
        end
    end
%%
    function update_all_aliases_FILE()
        [aliases,hashes,databases,types]=imapCommon.load_alias_DB_parts();
        all=[databases types hashes];
        %[~,ind]=unique(cell2mat(all(:,1:2)),'rows');
        %all=all(ind,:);
        for i = 1:size(all,1)
            imapCommon.update_aliases_FILE(all{i,1},all{i,2},all{i,3})
        end
    end
    function update_aliases_FILE(database,mod,hash)
        [aliases,hashes,databases,types]=imapCommon.load_alias_DB_parts();
        ind=ismember(databases,database) & ismember(types,mod) & ismember(hashes,hash);
        aliases=aliases(ind);

        lines=cell(numel(aliases),1);
        for i = 1:numel(aliases)
            lines{i}=imapCommon.gen_alias_line_FILE(database,mod,hash,aliases{i});
        end
        fname=imapCommon.get_alias_fname_FILE(database,mod,hash);
        dire=filePartsSane(fname);

        %% RM FROM DB IF DIRECTORY DOESN'T EXIST
        if ~exist(dire,'dir')
            for i = 1:length(aliases)
                imapCommon.rm_alias_DB(database,mod,hash,aliases{i});
            end
            return

        end

        cell2file(fname,lines);

    end
    function fname=get_alias_fname_FILE(database,mod,hash)
        dire=imapCommon.get_directory_f(database,mod,hash);
        fname=[dire '_aliases_.txt'];
    end
    function line=gen_alias_line_FILE(database,type,hash,alias)
        line=[hash ',' alias ',' database ',' type];
    end
    function add_alias_FILE(databse,mod,hash,alias)
        % NOTE NOT USED
        fname=imapCommon.get_alias_fname_FILE(database,mod,hash);
        line=gen_alias_line_FILE(database,type,hash,alias);
        cell2file(fname,line);
    end
%%
    function [out,prj]=exist_project_DB(hash,alias,database,type)
        % CODES
        % 1 - everything matches
        % 2 - different hash
        % 3 - hash under diff project
        [aliases,hashes,databases,types]=imapCommon.load_alias_DB_parts();
        out=any(ismember(aliases,alias) & ismember(databases,database) & ismember(types,type));



        if out == 1 && ismember(hash,hashes)
            % same hash & alias & type
            out=1;
        elseif out==1
            % same alias & type
            out=2;
        elseif ismember(hash,hashes)
            out=3;
        end
    end
    function rm_alias_DB(database,type,hash,alias)
        lines=imapCommon.get_aliases_DB();
        line=imapCommon.gen_alias_line_FILE(database,type,hash,alias);
        lines=lines(~ismember(lines,line));

        imapCommon.rewrite_alias_DB(lines);
    end
    function add_alias_DB(database,type,hash,alias)
        lines=imapCommon.get_aliases_DB();
        line=imapCommon.gen_alias_line_FILE(database,type,hash,alias);
        if ismember(line,lines)
            return
        end

        imapCommon.append_alias_DB(line);
    end
    function lines=get_aliases_DB()
        if imapCommon.exist_alias_fname_DB()
            lines=imapCommon.load_alias_DB();
        else
            lines={};
        end
    end
    function out=exist_alias_fname_DB()
        fname=imapCommon.get_alias_fname_DB();
        out=exist(fname,'file');
    end
    function fname=get_alias_fname_DB()
        dire=imapCommon.get_base_dir();
        fname=[dire '_alias_.txt'];
    end
    function lines=load_alias_DB()
        fname=imapCommon.get_alias_fname_DB();
        lines=file2cell(fname);
    end
    function [aliases,hashes,databases,types]=load_alias_DB_parts()
        lines=imapCommon.load_alias_DB();

        spl=cellfun(@(x) strsplit(x,','), lines,UO,false);
        lines=vertcat(spl{:});

        aliases=lines(:,2);
        hashes=lines(:,1);
        databases=lines(:,3);
        types=lines(:,4);
    end
    function rewrite_alias_DB(lines)
        fname=imapCommon.get_alias_fname_DB();
        cell2file(fname,lines)
    end
    function append_alias_DB(line)
        fname=imapCommon.get_alias_fname_DB();
        appendcell2file(fname,line);

    end
end
end
