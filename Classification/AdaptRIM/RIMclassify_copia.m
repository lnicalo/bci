function [class, score, model] = RIMclassify_copia(x,f,classes,init_model)

    N = size(x,1);
    K = x*x';
    KF = f*f';
    
    params.max_class = 2; % maximum number of clusters
    params.algo = 'kernel';  % may be 'kernel' or 'linear'
    params.lambda = 1; % regularization parameter
    params.sup_init = false;
    params.USEMEX = true;
    params.tau = 1;
    global test_classes;
    model = RIM(K,[],[],params,init_model);
    
    net = ALDAlearn(f,classes);
    w_0 = net.w';
    b_0 = net.b;
    
    w = model.alphas*K;
    if dot(w(1,:),w_0*x') < 0
        w = w(2:-1:1,:);
        model.bs = model.bs(2:-1:1,:);
    end
    D = 1./(1+exp(-(w + repmat(model.bs,[1 N]))));
    
    [score class] = min(D,[],1);
    score(class == 2) = 1 - score(class == 2);
end
