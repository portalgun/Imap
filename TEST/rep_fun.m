vals={transpose(1:3); transpose(1:6); transpose(1:4)};
allcounts=[3;6;4];
reps=rep_count_fun(allcounts)
N=prod(allcounts);
MAT=rep(N,vals,reps)
isequal(MAT,distribute(vals{:}))


function MAT=rep(N,vals,reps)
    MAT=zeros(N,size(reps,1));
    for i = 1:size(vals,1)
        A=repelem(vals{i},reps(i,1),1);
        MAT(:,i)=repmat(A, reps(i,2),1);
    end
end


function reps=rep_count_fun(allcounts)
    k=size(allcounts,1);
    reps=zeros(k,2);

    for i = 1:k
        reps(i,1)=prod(allcounts(i+1:end));
        reps(i,2)=prod(allcounts(1:i-1));
    end

end
