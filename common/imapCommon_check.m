classdef imapCommon_check < handle
methods
    function obj=check_all_fnames(obj,fnames,dire)
        if ~exist('fnames','var') || isempty(fnames)
            [obj,fnames]=obj.get_all_fnames();
        end
        if ~exist('dire','var') || isempty(dire)
            dire='';
        end

        %[~,names]=cellfun(@filePartsSane,fnames,UO,false);
        obj.imExists=false(size(fnames));
        for ind = 1:size(fnames,1)
        for k = 1:size(fnames,2)
            obj.imExists(ind,k)=logical(exist([dire fnames{ind,k} '.mat'],'file'));
        end
        end
    end
    function [obj,fnames]=get_all_fnames(obj)
        type=obj.get_type();
        fnames=cell(obj.nImg,obj.nLandR);
        for i = 1:obj.nImg
            obj.I=obj.imgNums(i);
            for kk  = 1:obj.nLandR
                obj.k=kk;
                obj.LorR=obj.LandR{kk};
                fnames{i,kk}=obj.get_fname(type);
            end
        end
    end
end
methods(Static=true)
    function missing=get_missing_files_f(imgNums,database,type,hash)
        switch type
               case 'dsp'
                    missing=imapCommon.get_missing_dsp_f(imgNums,database,hash);
               case 'pch'
                   missing=imapCommon.get_missing_ptch_f(imgNums,database,hash);
               case {'dmp_pch','dmp_dsp','sel'}
                   missing=imapCommon.get_missing_dmp_f(database,hash);
               otherwise
                   missing=imapCommon.get_missing_imap_f(imgNums,database,type,hash);
        end
    end
    function fname=get_missing_dmp_f(database,hash)
        dire=ptch.get_directory_p(database,hash);
        fname=[dire '_P_.mat'];
        missing=cell(1);
        if ~exist(fname,'file')
            missing{1}=fname;
        end
    end
    function missing=get_missing_dsp_f(imgNums,database,hash)
        DIRE=ptch.get_directory_p(database,hash);
        condDirs= XXX % XXX
        missing=cell(length(condDirs));
        for i = 1:length(condDirs)
            condDir = condDirs{i};
            dire=[DIRE condDir];
            missing{i}=imapCommon.get_missing_ptch_fun(imgNums,dire);
        end
    end
    function missing=get_missing_ptch_f(imgNums,database,hash)
        dire=ptch.get_directory_p(database,hash);
        missing=imapCommon.get_missing_ptch_fun(imgNums,dire);
    end
    function missing=get_missing_ptch_fun(imgNums,dire)
        missing=cell(length(imgNums),1);
        for ii = 1:length(imgNums)
            I=num2str(imgNums(ii),'%03d');
            re=['[LR]{1}' I '_[0-9]{3}_[0-9]{4}\.mat'];
            fnames=matchingFilesInDir(dire,re);
            if isempty(fnames)
                missing{ii}=re;
            end
        end

    end
    function missing=get_missing_imap_f(imgNums,database,type,hash)
        LandR={'L','R'};
        missing={};
        for i = 1:2
            LorR=LandR{i};
            missing=[missing imapCommon.get_missing_files_LorR_f(imgNums,database,type,hash,LorR)];
        end
    end
    function missing=get_missing_files_LorR_f(imgNums,database,type,hash,LorR)
        Ex=zeros(length(imgNums),1);
        fname=cell(length(imgNums),1);
        for ii = 1:length(imgNums)
            I=imgNums(ii);
            fname{ii}=imapCommon.get_fname_f(database,type,hash,I,LorR);
            Ex(ii)=exist(fname{ii},'file');
        end
        missing=fname(~Ex);
    end
    function []=print_missing_f(missing)
        disp('Missing files')
        for i = 1:length(missing)
            [~,name]=fileparts(missing{i});
            disp([S4 name]);
        end
    end
end
end
