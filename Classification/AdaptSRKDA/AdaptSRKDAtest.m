function out = AdaptSRKDAtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
     Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    eta = options.adaptParameter;
    
    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    classifier = model.classifier;
    MU = model.mu;
    clear model
    
    % Prediction
    for m = 1:Nsamples
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m};       
        
        % Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        
        % LDA classification
        [~, labels(:, m), scores(:, m, :)] = SRKDApredict(X, trueLabel, classifier{1, m});     
    end
    
    out = [];
    out.labels = labels;
    out.scores = scores;
end