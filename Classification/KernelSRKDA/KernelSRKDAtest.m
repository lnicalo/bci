function out = KernelSRKDAtest(features, model)

    options = model.options;       
    
    Ntrials  = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nobjects  = size(features.data, 3);
    Nclasses  = length(unique(features.trueLabel(~isnan(features.trueLabel))));
    
    labels = NaN(Ntrials, Nsamples*Nobjects);
    scores = NaN(Ntrials, Nsamples, Nclasses);
    
    trueLabel = features.trueLabel;
    classifier = model.classifier;
    trainFeatures = model.trainfea;
    clear model
    
    % Prediction  
    reverseStr = '';
    cont = 1;
    for m = 1:Nsamples
        Ftest = squeeze( features.data(:, m,:,:,:) );
        Ftrain = squeeze( trainFeatures(:, m,:,:,:) );
        % Computing multikernel        
        for i = 1:Nobjects            
            FOtest = squeeze( Ftest(:, i,:) );
            FOtrain = squeeze( Ftrain(:, i,:) );
            K = real( [FOtrain; FOtest] * [FOtrain; FOtest]' );
            
            % Normalizing
            D = diag(1./sqrt(diag(K)));
            K = D * K * D;                    
            K = K(end-Ntrials+1:end, 1:(end-Ntrials));
            
            % Train SVM
            [labels(:,cont), acc, p] = svmpredict(trueLabel', [(1:Ntrials)', K], classifier{i, m},'-q');          
            cont = cont + 1;
        end
        
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