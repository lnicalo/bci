function [class, score, model] = RIMclassify(x,f,classes,init_model)

    N = size(x,1);
    K = x*x';
    KF = f*f';
    
    params.max_class = 6; % maximum number of clusters
    params.algo = 'kernel';  % may be 'kernel' or 'linear'
    params.lambda = 1; % regularization parameter
    params.sup_init = false;
    params.USEMEX = true;
    params.tau = 1;
    global test_classes;
    model = RIM(K,[],[],params,init_model);
    
    D = 1./(1+exp(-(model.alphas*K + repmat(model.bs,[1 N]))));
    
    [score class] = max(D,[],1);
end
