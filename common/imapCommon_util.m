classdef imapCommon_util < handle
methods
    function type=get_type(obj)
        c=makeLowerCase(class(obj));
        c=strrep(c,'imap','');
        type=sed('s',c,'_.*','');
    end
    function imap=get_imap(obj,type,hash,k)
        if ~exist('type','var') || isempty(type)
            type=obj.TYPE;
        end
        if ~exist('hash','var') || isempty(hash)
            type=obj.hash;
        end
        if ~exist('k','var') || isempty(k)
            k=obj.k;
        end
        imap=imapCommon.get_imap_f(obj.database,type,hash,obj.I,k);
    end
    function fname=get_fname(obj,type)
        if ~exist('type','var') || isempty(type)
            type=obj.get_type;
        end
        fname=imapCommon.get_fname_f(obj.database,type,obj.hash, obj.I, obj.k);
    end
end
methods(Static=true)
    function edgesSmp=get_edges_smp(hsORa)
        hashes=imapCommon.auto_hashes(hsORa);
        edgesSmp=imapSmp.load_edges_f(hashes.database, hashes.smp);
    end
    function edgesBin=get_edges_bin(hsORa)
        hashes=imapCommon.auto_hashes(hsORa);
        edgesBin=imapBin.load_edges_f(hashes.database, hashes.bin);
    end
    function out=smp_bins_to_bin_vals(hsORa,bins)
        hashes=imapCommon.auto_hashes(hsORa);
        edgesBin=imapBin.load_edges_f(hashes.database, hashes.bin);
        edgesSmp=imapSmp.load_edges_f(hashes.database, hashes.smp);
        if exist('bins','var') && ~isempty(bins)
            edgesSmp=edgesSmp(bins);
        end


        A=find(ismember(edgesBin,edgesSmp));
        B=A+1;
        ind1=transpose(edgesBin(A));
        ind2=transpose(edgesBin(B));

        out=[ind1 ind2];
    end
    function out=smp_bins_to_bin_bins(hsORa,bins)
        hashes=imapCommon.auto_hashes(hsORa);
        edgesBin=imapBin.load_edges_f(hashes.database, hashes.bin);
        edgesSmp=imapSmp.load_edges_f(hashes.database, hashes.smp);
        if exist('bins','var') && ~isempty(bins)
            edgesSmp=edgesSmp(bins);
        end
        out=find(ismember(edgesBin,edgesSmp));
    end
    function out=bin_bins_to_smp_bins(hsORa,bins)
        hashes=imapCommon.auto_hashes(hsORa);
        edgesBin=imapBin.load_edges_f(hashes.database, hashes.bin);
        edgesSmp=imapSmp.load_edges_f(hashes.database, hashes.smp);
        if exist('bins','var') && ~isempty(bins)
            edgesBin=edgesBin(bins);
        end
        out=find(ismember(edgesSmp,edgesBin));
    end
    function p=get_patch(database,type,hash,I,k,PctrRC,PszRC)
        hashes=struct(type,hash);
        srcInf=srcInfo(database,hashes,I,k,PctrRC);
        p=ptch(PszRC,[],srcInf);
    end
    function imap=get_imap_f(database,type,hash,I,k)
        imap=dbImg.get_img(database,type,hash,I,k);
    end
    function dire=get_directory_f(database,type,hash)

        if strcmp(type,'pch')
            dire=ptch.get_directory_p(database,hash);
        elseif strcmp(type,'dsp')
            % XXX
            dire=ptch.get_directory_dsp_p(database,hash);
        elseif strcmp(type,'sel')
            dire=ptch.get_directory_dsp_p(database,hash);
        else
            dbDir=imapCommon.get_dbDir(database, type);
            dire=[dbDir type filesep hash filesep];
        end
    end
    function dire=get_mod_dir(database,mod)
        dire=imapCommon.get_dbDir(database,mod);
        if ~endsWith(dire,filesep)
            dire=[dire filesep];
        end
        if ~ismember(mod,imapCommon.modules)
            error(['invalid module name: ' mod]);
        end
        if startsWith(mod,'imap')
            mod=strrep(mod,'imap','');
        end
        mod=makeLowerCase(mod);
        if startsWith(mod,'dmp_')
            mod=strrep(mod,'dmp_','');
        elseif endsWith(mod,'_dmp')
            mod=strrep(mod,'_dmp','');
        end

        dire=[dire mod filesep];
    end
    function dire=get_dbDir(database,type)
        ptch={'pch','dsp','sel','dmp_pch','dmp_dsp','dmp_sel'};
        if ismember(type,ptch)
            dire=imapCommon.get_ptchDBdir(database);
        elseif strcmp(type,'prb')
            dire=imapCommon.get_prbDBdir(database);
        else
            dire=imapCommon.get_rootDBdir(database);
        end
    end
    function dire=get_base_dir()
        dire=imapCommon.get_rootDBdir('base');
    end
    function dire=get_prbDBdir(database)
        dire=imapCommon.get_rootDBdir([database 'prb']);
    end
    function dire=get_rootDBdir(database)
        dire=BLdirs(database);
    end
    function dire=get_ptchDBdir(database)
        dire=imapCommon.get_rootDBdir([database 'ptch']);
    end
    function fname=get_fname_f(database,imgType,hash,I,LorR)
        LR='LR';
        if isnumeric(LorR)
            LorR=LR(LorR);
        end
        name=[LorR  num2str(I,'%03i')];
        dire=imapCommon.get_directory_f(database,imgType,hash);
        fname=[dire name];
    end
    function mv_files(database1,type1,hash1, database2,type2,hash2)
        %% NOTE HASHES MAY BE STILL WRONG, SO RUN BEFORE SAVING DEF ETC
        %[fnames,bDir,dire]=imapCommon.get_file_names(database1,type1,hash1);
        %bDir=logical(bDir);
        %dirs=fnames(bDir);
        %fnames=fnames(~bDir);

        dire=imapCommon.get_directory_f(database1,type1,hash1);
        destDire=imapCommon.get_directory_f(database2,type2,hash2);

        p=pr(1,1,'Moving files');
        movefile(dire,destDire);
        p.c();


    end
    function rm_files(database,type,hash)
        [fnames,bDir,dire]=imapCommon.get_file_names(database,type,hash);
        dirs=fnames(logical(bDir));
        fnames=fnames(~bDir);
        for i = 1:length(fnames)
            f=[dire fnames{i}];

            delete(f);
        end
        for i = 1:length(dirs)
            d=[dire dirs{i}];

            %disp(d)
            rmdir(d);
        end

        %disp([newline dire])
        rmdir(dire);
    end
    function [FNAMES,bDir,dire]=get_file_names(database,type,hash)
        switch type
        case 'vet'
            re=imapVet.get_files_regexp();
        case 'gen'
            re=imapGen.get_files_regexp();
        case 'bin'
            re=imapBin.get_files_regexp();
        case 'smp'
            re=imapSmp.get_files_regexp();
        case 'pch'
            re=imapPch.get_files_regexp();
        case 'dsp'
            re=imapDsp.get_files_regexp();
        case 'sel'
            re=imapSel.get_files_regexp();
        end

        dire=imapCommon.get_directory_f(database,type,hash);
        FNAMES={};
        bDir=[];
        for i = 1:length(re)
            r=re{i};
            if regExp(r(1:end-1),filesep)
                [ind1,ind2]=regexp(r,['.*' filesep]); % greedy match
                rdire=r(ind1:ind2);

                r2=r(ind2+1:end);
                dires=matchingDirsRecurs([dire rdire]);
                subdir=strrep(dires,dire,'');
                fnames={};
                for d = 1:length(dires)
                    f=matchingFilesInDir(dires{d},r2);
                    if isempty(f)
                        bDir=[bDir; true(length(dires),1)];
                    else
                        bDir=[bDir; false(length(f),1)];
                    end

                    F=strcat(subdir{d},f);
                    fnames=[fnames; F];
                end

            elseif endsWith(r,filesep)
                r=r(1:end-1);
                [fnames]=matchingDirsInDir(dire,r);
                bDir=[bDir; true(length(fnames),1)];
            else
                [fnames]=matchingFilesInDir(dire,r);
                bDir=[bDir; false(length(fnames),1)];
            end
            FNAMES=[FNAMES; fnames];
        end
    end
    function [bNoFiles,bNoDirs,filesfull,dirs]=prj_isempty(database,module,hash)
        % ANY IGNORE DIRS?
        ignoreFiles={'_aliases_.txt';'_def_.yaml';'_def_.mat';'_edges_.mat';'_genOpts.mat';'_status_.txt'};
        dire=imapCommon.get_directory_f(database,module,hash);

        [files,filesfull]=filesInDir(dire);
        [~,dirs]=dirsInDir(dire);

        %ignoreFiles

        bNoFiles=any(~ismember(files,ignoreFiles));

        files(ismember(files,ignoreFiles))=[];
        bNoFiles=isempty(files);
        %if length(files) < 10
        %    files
        %end

        bNoDirs=isempty(dirs);
    end
    function rm_all_dirs_if_empty(database)
        mods=imapCommon.modules;
        for i = 1:length(mods)
            mod=mods{i};
            if startsWith(mod,'dmp_') || endsWith(mod,'_dmp')
                continue
            end
            modDire=imapCommon.get_mod_dir(database,mod);
            hashes=dirsInDir(modDire);

            for j = 1:length(hashes)
                imapCommon.rm_dir_if_empty(database,mod,hashes{j});
            end
        end
    end
    function []=rm_dir_if_empty(database,mod,hash)

        [bNoFiles,bNoDirs,files,dirs]=imapCommon.prj_isempty(database,mod,hash);
        if bNoFiles & bNoDirs
            disp([mod ' ' hash]);
            for i = 1:length(files)
                %disp([ '    ' files{i}] ); %TESTING
                delete(files{i});
            end
            dire=imapCommon.get_directory_f(database,mod,hash);
            rmdir(dire);
        end
    end


end
end
