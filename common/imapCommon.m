classdef imapCommon < handle & imapCommon_check & imapCommon_def & imapCommon_hash & imapCommon_img & imapCommon_plot & imapCommon_util & imapCommon_alias
properties
    database
    hash
    hashes=struct()
end
properties(Constant=true, Hidden=true)
    modules={'vet','gen','bin','smp','pch','dmp_pch','dsp','dmp_dsp','sel'};
end
properties(Hidden=true)
    missing

    IszRC
    nImg
    imgNums
    imExists

    prog
    plotOpts
end
end
