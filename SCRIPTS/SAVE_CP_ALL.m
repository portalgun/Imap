database='LRSI';

db=subdbInfo(database,'img','xyz');

N=length(db.gdImages);
p=pr(N,1);
for i = 1:N
    I=db.gdImages(i);
    xyz=XYZ(database, I, db);

    xyz.save_CPs_all();
    p.u();
end
p.c();
%vet/513a62cc9782ad76c7f12059e4c4dcb0' does not exist.
%123 imap common
