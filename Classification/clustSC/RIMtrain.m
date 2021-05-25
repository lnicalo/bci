function model = SCtrain(fea, gnd, options)
    Nsamples = size(fea, 1);
    Nclasses = length(unique(gnd));
     
    K = fea * fea' + 100*eye(Nsamples);
   
    params.max_class = Nclasses; % maximum number of clusters
    params.algo = 'kernel';  % may be 'kernel' or 'linear'
    params.lambda = 1; % regularization parameter
    params.sup_init = false;
    params.USEMEX = true;
    params.tau = 1;
    
    init_model.alphas = randn(Nclasses, Nsamples);
    init_model.bs = zeros(Nclasses, 1);%randn(params.max_class,1);
    model = RIM(K,[],[],params,init_model);
    model.options = options;
    model.fea = fea;
    
    model.accuracy = RIMpredict(fea, gnd, model);    
end
