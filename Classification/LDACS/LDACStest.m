function out = AdaptLDACStest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length( model.classifier{1,1}.ClassLabel );
    Nsubjects = size(model.classifier, 1);
    
    eta = options.adaptParameter;
    
    labels = NaN(Ntrials, Nsamples, Nsubjects);
    scores = NaN(Ntrials, Nsamples, Nclasses, Nsubjects);
    
    trueLabel = features.trueLabel;
    modelLDA = model.classifier;
    MU = model.mu;
    clear model
    
    % Prediction
    weights = NaN(Nsubjects, Nsamples);
    for m = 1:Nsamples
        X = squeeze( features.data(:, m,:) );
        X = reshape( X, Ntrials, [], Nsubjects);
        
        for u = 1:Nsubjects
            mu = MU{u, m};  
            Fu = squeeze( X(:,:,u) );
            % Adaptation
            for trial = 1:Ntrials;
                aux = Fu(trial,:);
                mu = (1 - eta) * mu + eta * aux;
                Fu(trial,:) = aux - mu;
            end
            
            % LDA classification
            [~, labels(:, m, u), scores(:, m, :, u)] = LDApredict(Fu, trueLabel, modelLDA{u, m});
            weights(u, m) = modelLDA{u,m}.acc;
        end
    end
    
    % Majority vote
    votes = NaN(Ntrials, Nsamples, Nclasses);
    weights_ = NaN(1, Nsamples, Nsubjects);
    weights_(1,:,:) = (weights' - 0.5) / Nsubjects;
    for i = 1:Nclasses
        aux = (labels == i) .* repmat(weights_ > 0.35/Nsubjects, [Ntrials, 1, 1]);
        votes(:,:,i) = sum(aux, 3);
    end
    [~, labels] = max(votes, [], 3);
    
    % 
    scores = squeeze( mean(scores, 4) );
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