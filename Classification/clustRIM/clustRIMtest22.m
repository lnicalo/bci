function out = clustRIMtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length( model.classLabel );
    
    eta = options.adaptParameter;
    
    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    classifier = model.classifier;
    MU = model.mu;
    clear model
    
    % Prediction
    reverseStr = '';
    fea = [];
    gnd = [];
    for m = 60:90 % Nsamples
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m};       
        
        % Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        fea = cat(1, fea, X);
        gnd = cat(2, gnd, trueLabel);
    end
    % LDA classification
    classifier = RIMtrain(fea, gnd, options);
    
    for m = 1:Nsamples
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m}; 
        
        % Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        [~, labels(:, m), scores(:, m, :)] = RIMpredict(X, trueLabel, classifier);
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Prediction: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
    
    % Post filter
    h = ones(1,1);
    scores = filter(h,1,scores, [], 2);
    [~, labels] = max(scores,[], 3);
    
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