dire='/Volumes/Data/.daveDB/img/LRSI/vet/513a62cc9782ad76c7f12059e4c4dcb0/';
regexp='R[0-9]{3}\.mat';
LR='LR';

files= regexpdir(dire,regexp);
for i = 1:length(files)
    handle=files{i};
    file=[dire handle];
    load(file);
    file=strrep(file,'.mat','');
    for k = 1:2
        imap=vet{k};
        fname=[dire strrep(handle,'R',LR(k))];
        save(fname,'imap');
    end
end
