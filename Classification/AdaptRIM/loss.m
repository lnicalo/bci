function loss_value = loss(x,n_class)

    likelihood = 0;
    
    N = size(x,2);
    A_max = max(x,[],1);
    x = x - A_max(ones(n_class,1),:);
    p = exp(x);
    Z= sum(p,1);
    p = p./Z(ones(n_class,1),:); 
    
    zero_idx = (p==0);
    P = sum(p,2)/N;
    
    %p_log_p_over_P = zeros(params.max_class,N_unlabeled,'single');
    rep_P = P(:,ones(1,N));

    %p_log_p_over_P(nz_idx) = p(nz_idx).*log(p(nz_idx)./rep_P(nz_idx));
    p_log_p_over_P = p.*log(p./rep_P);
    p_log_p_over_P(zero_idx) = 0;
    p_log_p_over_P(P==0,:) = 0;

    CB = sum(P(P>0).*log(P(P>0)));
    PW = -sum(sum(p(p>0).*log(p(p>0))));

    KL = sum(p_log_p_over_P,1);
    rep_KL = KL(ones(n_class,1),:);
    
    info = -sum(KL)/1;
    loss_value = - likelihood + info;
    
    % display([' H_class: ' num2str(-CB) ' H_cond: ' num2str(PW/N)]);
    % display([' Info: ' num2str(info) ' Loss Value:' num2str(loss_value)]);
end