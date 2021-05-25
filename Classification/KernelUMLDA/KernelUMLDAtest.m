function out = KernelUMLDAtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    labels = NaN(Ntrials, Nsamples);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    classifier = model.classifier;
    modelLDA = model.modelLDA;
    clear model
    
    % Prediction  
    numP = options.numP;
    reverseStr = '';
    projectedFea = zeros(Ntrials, numP);
    for m = 1:Nsamples
        F = squeeze( features.data(:, m,:,:,:) );
        F = abs( permute(F,[2 3 4 1]) );
        mClassifier = classifier{1, m};
        
        for iP = 1:numP
            projFtr = ttv(tensor(F), mClassifier(:,iP), [1 2 3]); %Projection
            projectedFea(:, iP) = projFtr.data;
        end
        
        % LDA classification
        [~, labels(:, m), scores(:, m, :)] = LDApredict(projectedFea, trueLabel, modelLDA{1, m});     
        
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