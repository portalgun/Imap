classdef imapSel_Tlvl < handle
methods
end
methods(Static=true)
    function [Table]=get_lvl_table(stdStruct)
        %stdStruct=struct();
        %stdStruct.dsp=[-3; -7; ];
        %stdStruct.spd=[8; 9; 10;];
        %stdStruct.winPszRCm=[10 10; 9 9; 8 8];
        %stdStruct.wdw=[1];

        nameKey=fieldnames(stdStruct);
        inds=cell(1,length(nameKey));
        valKey=cell(1,length(nameKey));
        unitKey=cell(1,length(nameKey));
        for i = 1:length(nameKey)
            k=nameKey{i};
            inds{i}=1:size(stdStruct.(k).vals);
            valKey{i}=stdStruct.(k).vals;
            unitKey{i}=stdStruct.(k).units;
        end
        tableInds=distribute(inds{:});

        Table=struct();
        Table.inds=tableInds;
        Table.valKey=valKey;
        Table.nameKey=nameKey;
        Table.unitKey=unitKey;

    end
end
end
