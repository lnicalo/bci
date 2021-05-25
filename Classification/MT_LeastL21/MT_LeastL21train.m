function model = MT_LeastL21train(features, options)

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
        % Regularization Type
        options.tol = 10^-5;
    end
    
    if ~isfield(options,'maxIter')
        % Max. Iterations
        options.maxIter = 1000;
    end
    
    if ~isfield(options,'lambda')
        % Sparsity parameter
        options.lambda = 0.3;
    end
    
    if ~isfield(options,'adaptParameter')
        % Adaptive parameter
        options.adaptParameter = 0.0;
    end
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 0;
    end
    
    model = [];
    model.ID = 'MT_LeastL21';
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
        [W, C] = Least_L21(X, Yc, options.lambda, options);
        model.classifier{i, 1}.W = W;
        model.classifier{i, 1}.C = C;
    end
end