function out = AdaptLASSOtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    eta = options.adaptParameter;
    eta = 0;
    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples);
    
    trueLabel = features.trueLabel;
    classifier = model.classifier;
    MU = model.mu;
    clear model
    
    Nfeatures = size(features.data, 3) + 1;
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
        X = [ones(size(X,1),1) X];
        [scores(:, m), labels(:,m)] = max(X*[classifier{1, m} zeros(Nfeatures,1)],[],2);
    end
    
    out = [];
    out.labels = labels;
    out.scores = scores;
end