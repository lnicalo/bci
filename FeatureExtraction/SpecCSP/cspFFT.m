function W = cspFFT(S1,S2,m) 
    [~,C,~,L] = size(S1);
    
    S1_mean = squeeze(mean(S1,1));
    S2_mean = squeeze(mean(S2,1));
    
    W = NaN(C,2*m,L);
    for l = 1:L   
        % CSP
        [w,D] = eig(squeeze(S1_mean(:,:,l)),squeeze(S1_mean(:,:,l)+S2_mean(:,:,l)));
        [~,ind] = sort(diag(D),'descend');
        W(:,:,l) = w(:,ind([1:m (end-m+1):end],1));
    end    
end