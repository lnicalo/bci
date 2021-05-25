function model = MT_CMTLtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'init')
        % Reguralization
        options.init = 0;
    end
    
    if ~isfield(options,'tFlag')
        % Regularization Parameter
        options.tFlag = 1;
    end
    
    if ~isfield(options,'tol')
        % Tolerance
        options.tol = 10^-6;
    end
    
    if ~isfield(options,'maxIter')
        % Num. of max iterations
        options.maxIter = 1500;
    end
    
    if ~isfield(options,'rho1')
        % clustering penalty controlling parameter
        options.rho1 = 1;
    end
    
    if ~isfield(options,'rho2')
        % L2 norm regularization on model. ( > 0)
        options.rho2 = 1;
    end
    
    if ~isfield(options,'rho3')
        % Adaptive parameter
        options.rho3 = 0.01;
    end
    
    if ~isfield(options,'adaptParameter')
        % Adaptive parameter
        options.adaptParameter = 0.5;
    end
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 0;
    end
    
    model = [];
    model.ID = 'MT_CMTL';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    model.classifier = cell(1, Nsamples);
    model.mu = cell(1, Nsamples);    
    X = cell(1, Nsamples);
    Y = cell(1, Nsamples);
    
    for m = 1:Nsamples
        F = squeeze( features.data(:, m,:) );
        mu = mean(F,1);        
        F = F - repmat(mu, [size(F,1) 1]);
        
        X{1, m} = F;
        model.mu{1, m} = mu; 
        
        Y{1, m} = features.trueLabel'; 
    end
    
    labels = unique(features.trueLabel);
    Nclasses = length(labels);
    model.classifier = cell(Nclasses, 1);
    
    for i = 1:Nclasses
        Yc = cell(1, Nsamples);
        aux = Y{1, 1};
        aux = 1 * (aux == labels(i)) - 1 * (aux ~= labels(i));
        for t = 1:Nsamples            
            Yc{1, t} = aux;
        end
        [W, C] = Logistic_CFGLasso(X, Yc, options.rho1, options.rho2, options.rho3, options);
        model.classifier{i, 1}.W = W;
        model.classifier{i, 1}.C = C;
    end
end