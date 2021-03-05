classdef imapDsp_Tind < handle
methods(Static=true)
%% DSP ind
    function dire=get_directories_ind_p(database,indHash)
        ptch.get_directory_dsp_p(database,indHash);
    end
    function dire=get_directory_ind_p(database,indHash)
        database=[database 'ptch'];
        rootDBdir=imapCommon.get_rootDBdir(database);
        dire=[rootDBdir 'dsp' filesep indHash filesep];
    end
    function dire=get_directories_p(database,hash)
        indHashes=ptch.load_dsp_ind_p(database,hash);
        for i = 1:length(hashes)
            dire=get_directory_dsp_ind_p(database,indHashes{i});
        end
    end
    function ind=load_ind_p(database,hash)
        fname=get_dsp_ind_fname(database,hash)
        load(fname);
    end
    function fname=get_dsp_fname(database,hash)
        dire=ptch.get_directory_dsp_p(database,indHash);
        fname=[dire '_ind'];
    end
end
end
