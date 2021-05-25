function model = KernelUMLDAtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'Regu')
        % Reguralization
        options.Regu = 10;
    end    
    
    if ~isfield(options,'gamma')
        % Reguralization
        options.gamma = 10^-2;
    end 
    
    if ~isfield(options,'numP')
        % Reguralization
        options.numP = 20;
    end 
    
    if ~isfield(options,'Regu')
        % Reguralization
        options.Regu = true;
    end
    
    if ~isfield(options,'ReguAlpha')
        % Regularization Parameter
        options.ReguAlpha = 50;
    end
    
    if ~isfield(options,'ReguType')
        % Regularization Type
        options.ReguType = 'Ridge';
    end
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 1;
    end
    
    model = [];
    model.ID = 'KernelUMLDA';
    model.options = options;    
    
    % Training
    Ntrials = size(features.data, 1);
    Nsamples = size(features.data, 2);
    
    model.classifier = cell(1, Nsamples);
    model.modelLDA   = cell(1, Nsamples);
    
    numP = options.numP;
    reverseStr = '';
    projectedFea = zeros(Ntrials, numP);
    for m = 1:Nsamples
        F = abs( squeeze( features.data(:, m,:,:,:) ) );
        F = permute(F,[2 3 4 1]);
        
        MaxSWLmds = estMaxSWEV(F, features.trueLabel);        
        model.classifier{1, m} = RUMLDA(F, features.trueLabel, numP, options.gamma, MaxSWLmds, 1);
        
        mClassifier = model.classifier{1, m};
        
        for iP = 1:numP
            projFtr = ttv(tensor(F), mClassifier(:,iP), [1 2 3]); %Projection
            projectedFea(:, iP) = projFtr.data;
        end
        
        model.modelLDA{1, m} = LDAtrain(projectedFea, features.trueLabel, options);
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Training: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
end