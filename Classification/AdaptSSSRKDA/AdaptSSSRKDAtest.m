function out = AdaptSSSRKDAtest(features, model)
    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length(unique(features.trueLabel));
    
    eta = options.adaptParameter;
    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    classifier = model.classifier;
    MU = model.mu;
    clear model
    
    % Prediction
    tiempo = NaN(size(features.data,1), 10);
    for m = 55:80
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m};       
        
        % EWMA Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;            
        end
        
        % SS-SRKDA classification
        if options.semiSupervised
            % Semi-supervised SRKDA
            [~, labels(:, m), ~] = SSSRKDApredict(X, trueLabel, classifier{1, m});
        else
            % SRKDA
            [~, labels(:, m), scores(:, m, :)] = SRKDApredict(X, trueLabel, classifier{1, m});
        end
        acc = cumsum(labels(:, m)' == trueLabel)./(1:Ntrials);
    end
    
    out = [];
    out.labels = labels;
    out.scores = scores;
end