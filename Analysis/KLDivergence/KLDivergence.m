function KL = KLDivergence(trainFeat, testFeat)
Nsample = size(trainFeat, 2);
KL = NaN(Nsample, 1);

for t = 1:Nsample
    disp(t)
    x1 = squeeze( trainFeat(:,t,:) );
    x2 = squeeze( testFeat(:,t,:) );
    
    mu1 = mean(x1,1);
    mu2 = mean(x2,1);
    
    C1 = cov(x1,1);
    C2 = cov(x2,1);
    
    KL(t,1) = 0.5 * ( ((mu1 - mu2)/C1)*(mu1 - mu2)' + ...
        trace(C1\C2) - log(det(C2)/det(C1)) - size(trainFeat,3));
end
end