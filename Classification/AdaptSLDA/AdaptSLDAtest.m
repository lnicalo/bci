function out = AdaptSLDAtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    eta = options.adaptParameter;
    
    labels = NaN(Ntrials, Nsamples);
    aux_scores = NaN(Ntrials, Nsamples, Nclasses - 1);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    modelLDA1 = model.modelLDA1;
    MU = model.mu;
    
    %% Stacked generalization
    %% Level - 0
    data = features.data;
    trueLabel = features.trueLabel;
    clear features;
    
    parfor m = 1:Nsamples
        X = squeeze( data(:, m, :) );
        mu = MU{1, m};       
        
        % Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        
        % LDA projection
        aux_scores(:,m,:) = X * modelLDA1{1, m}.eigvector;
    end
    
    %% Level - 1
    optLevel2 = options.optLevel2;
    modelLDA2 = model.modelLDA2;
    
    
    for m = 1:Nsamples
        train_scores_m = aux_scores( :, ...
            max( m - optLevel2.W + 1,1) : m, :);
        train_scores_m = train_scores_m(:,:);
        
        % LDA classification
        [~, labels(:, m), scores(:, m, :) ] = LDApredict(train_scores_m, trueLabel, modelLDA2{1, m});   
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