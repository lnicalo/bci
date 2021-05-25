function out = MPMLDAtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    modelLDA = model.modelLDA;
    MU = model.mu;
    eta = options.adaptParameter1;
    beta = options.adaptParameter2;
    equal = options.equal;
    clear model
    
    % Prediction
    if isfield(options, 'time')
        v = options.time;
    else
        v = 1:Nsamples;
    end
    parfor m = v
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m};       
        
        % Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        
        % LDA classification
        if beta > 0
            [~, labels(:, m), scores(:, m, :)] = adaptMLDApredict(X, trueLabel, modelLDA{1, m}, beta, equal);     
        else
            [~, labels(:, m), scores(:, m, :)] = MLDApredict(X, trueLabel, modelLDA{1, m});             
        end
    end
    
    out = [];
    % If options.time exists, a single answer is given
    % Otherwise, continuous feedback
    if isfield(options,'time')
        out.labels = labels(:, options.time);
        out.scores = scores(:, options.time);
    else
        out.labels = labels;
        out.scores = scores;
    end
end