function model = clustRIMtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
       
    if ~isfield(options,'adaptParameter')
        % Adaptive parameter
        options.adaptParameter = 0;
    end
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 0;
    end
    
    model = [];
    model.ID = 'clustRIM';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    classifier = cell(1, Nsamples);
    mu = cell(1, Nsamples);
    model.classLabel = unique(features.trueLabel);

    parfor m = 1:Nsamples
        F = squeeze( features.data(:, m,:) );
        mu_ = mean(F,1);        
        F = F - repmat(mu_, [size(F,1) 1]);
        
        mu{1, m} = mu_;
        classifier{1, m} = RIMtrain(F, features.trueLabel, options);         
    end
    
    model.mu = mu;
    model.classifier = classifier;
    
end