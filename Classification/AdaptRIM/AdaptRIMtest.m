function out = AdaptRIMtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
     Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    eta = options.adaptParameter;
    
    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    modelLDA = model.modelLDA;
    MU = model.mu;
    trainFeatures = model.trainFea;
    trainLabels = model.labels;
    clear model
    
    Ntrain = size(trainFeatures{1,1}, 1);
    Ntest  = size(features.data, 1);
    Dtrain = zeros(Ntrain, Nclasses);
    ind = sub2ind([Ntrain Nclasses],1:Ntrain, trainLabels);
    Dtrain(ind) = 1;
    
    % Prediction
    for m = 80
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m};       
        
        % Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        
        % LDA projection
        projection = X*modelLDA{1, m}.eigvector;  
        scatter3(projection(:,1), projection(:,2), projection(:,3),10,features.trueLabel)
        title(sprintf('Sample %i', m));
        pause(0.1)
        
        
        %% Label propagation   
        F = trainFeatures{1, m};
        S = [F;X];
        S = S*S';
        Suu = S(Ntrain+1:Ntest+Ntrain,Ntrain+1:Ntest+Ntrain);
        Suu = normr(Suu);
        Sul = S(Ntrain+1:Ntest+Ntrain,1:Ntrain);
        Sul = normr(Sul);
        p = (eye(Ntest) + Suu)\(Sul*Dtrain);
        [~,labels] = max(p,[],2);
        labels(:,m) = labels';
        
        Subspace_Alignment(F,X,trainLabels,features.trueLabel,3)

    end
    
    out = [];
    out.labels = labels;
    out.scores = scores;
end