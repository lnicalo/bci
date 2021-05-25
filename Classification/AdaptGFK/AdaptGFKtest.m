function out = AdaptGFKtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    eta = options.adaptParameter;

    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    classifier = model.classifier;
    trainLabels = model.labels;
    
    MU = model.mu;
    clear model
    
    % Prediction
    reverseStr = '';
    for m = 1:Nsamples
        X = squeeze( features.data(:, m,:) );
        mu = MU{1, m};       
        
        % Adaptation
        for trial = 1:Ntrials;
            aux = X(trial,:);
            mu = (1 - eta) * mu + eta * aux;
            X(trial,:) = aux - mu;
        end
        
        Ps = classifier{1, m}.Ps;
        F  = classifier{1, m}.F;
        
        Pt = princomp(X);  % target subspace
        G = GFK([Ps, null(Ps')], Pt(:,1:end));
        % G = eye(85);
        Ktrain = F * G * F';
        Ktest  = X * G * F';     
        
        
        Ntrain = size(Ktrain, 2);
        Ntest  = size(Ktest, 2);

        model_precomputed = svmtrain(trainLabels', [(1:Ntrain)', Ktrain], '-t 0 -q');
        labels(:, m) = svmpredict(trueLabel', [(1:Ntest)', Ktest], model_precomputed, '-q');
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Training: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
    
    out = [];
    out.labels = labels;
    out.scores = scores;
end


function [prediction accuracy] = my_kernel_knn(M, Xr, Yr, Xt, Yt)
dist = repmat(diag(Xr*M*Xr'),1,length(Yt)) ...
    + repmat(diag(Xt*M*Xt')',length(Yr),1)...
    - 2*Xr*M*Xt';
[~, minIDX] = min(dist);
prediction = Yr(minIDX);
accuracy = sum( prediction==Yt ) / length(Yt); 
end
