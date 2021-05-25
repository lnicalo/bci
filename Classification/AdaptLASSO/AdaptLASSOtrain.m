function model = AdaptLASSOtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'Regu')
        % Reguralization
        options.alpha = 0.3;
    end    
    
    if ~isfield(options,'adaptParameter')
        % Adaptive parameter
        options.adaptParameter = 0.05;
    end
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 1;
    end
    
    model = [];
    model.ID = 'AdaptLASSO';
    model.options = options;    
    
    % Training
    Ntrials = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nfeatures = size(features.data, 3) + 1;
    Nclasses = length(unique(features.trueLabel));
    
    model.classifier = cell(1, Nsamples);
    model.mu = cell(1, Nsamples);
    
    reverseStr = '';
    trueLabel = features.trueLabel';
    for m = 1 : Nsamples
        F = squeeze( features.data(:, m,:) );
        mu = mean(F,1);        
        F = F - repmat(mu, [size(F,1) 1]);        
        F = [ones(Ntrials,1) F];
        
        w = randn(Nfeatures,Nclasses-1).*(rand(Nfeatures,Nclasses-1)>.5);
        
        
        % Initialize Weights and Objective Function
        w_init = zeros(Nfeatures,Nclasses-1);
        w_init = w_init(:);
        funObj = @(w)SoftmaxLoss2(w,F, trueLabel,Nclasses);
        
        
        % Set up regularizer
        lambda = 1*ones(Nfeatures,Nclasses-1);
        lambda(1,:) = 0; % Don't regularize bias elements
        lambda = lambda(:);
        funObjL2 = @(w)penalizedL2(w,funObj,lambda);
        
        model_it = L1General2_PSSgb(funObj,w_init,lambda);
        model_it = reshape(model_it,Nfeatures,Nclasses-1);
        
        model.mu{1, m} = mu;
        model.classifier{1, m} = model_it;

        [~, yhat] = max(F*[model_it zeros(Nfeatures,1)],[],2);
        acc(m,1) = mean( trueLabel == yhat);
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Training: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
end