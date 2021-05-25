function [Dist,pm,dmax] = simatrix_ap(data,type,chois)
% data: a matrix with each column representing a variable.

pm = NaN;
dmax = 1;
if type == 1
    [Dist, dmax] = similarity_euclid(data);
else
    Dist = 1-(1+similarity_pearson(data'))/2;
end
Dist = -Dist;

if chois
    nrow = size(Dist,1);
    nap = nrow*nrow-nrow;
    M = zeros(nap,3);
    j = 1;
    for i=1:nrow
        for k = [1:i-1,i+1:nrow]
            M(j,1) = i;
            M(j,2) = k;
            M(j,3) = Dist(i,k);
            j = j+1;
        end
    end
    pm = median(M(:,3));
    Dist = M;
end