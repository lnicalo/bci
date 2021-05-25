function W = CSP_adapt(scms,W0)
    options = optimset('GradObj','off','Algorithm','active-set','Display','iter','MaxIter',1000,'MaxFunEvals',10000);  
    [W,~] = fmincon(@(w) obj_unsuperv(scms,w),W0,[],[],[],[],[],[],@(w) constraint(w),options);
    % [W,~] = fminsearch(@(w) obj_unsuperv(scms,w,Nclases),W0,options);
end