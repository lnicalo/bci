function out = MT_CMTLtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    eta = options.adaptParameter;

    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    classifier = model.classifier;
    MU = model.mu;
    clear model
    
    %% Prediction
    % Adaptation
    for m = 1:Nsamples
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m};       
        
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        
        for i = 1:Nclasses
            W = classifier{i, 1}.W;
            C = classifier{i, 1}.C;
            scores(:, m, i) = X * W(:, m) + C(:, m);
        end
    end
    
    % Classification
    [~, labels] = max( scores, [], 3);    
    out = [];
    out.labels = labels;
    out.scores = scores;
end