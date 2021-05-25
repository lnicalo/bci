function model = AdaptSSSRKDAtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'ReguAlpha')
        % Regularization Parameter
        options.ReguAlpha = 85;
    end
    
    if ~isfield(options,'ReguType')
        % Regularization Type
        options.ReguType = 'Ridge';
    end
    
    if ~isfield(options, 'KernelType')
        options.KernelType = 'Linear';
    end
    
    if ~isfield(options,'adaptParameter')
        % Adaptive parameter
        options.adaptParameter = 0.0;
    end
    
    if ~isfield(options,'semiSupervised')
        % Semi-supervised classification ?
        options.semiSupervised = false;
    end
    
    if ~isfield(options,'th')
        % Threshold - Only it applies for semi-supervised classification
        options.th = 0;
    end
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 1;
    end
    
    model = [];
    model.ID = 'AdaptSSSRKDA';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    classifier = cell(1, Nsamples);
    mu = cell(1, Nsamples);    
    parfor m = 1:Nsamples
        F = squeeze( features.data(:, m,:) );
        mu_ = mean(F,1);        
        F = F - repmat(mu_, [size(F,1) 1]);
        
        mu{1, m} = mu_;
        classifier{1, m} = SRKDAtrain(F, features.trueLabel, options);  
        classifier{1, m}.gnd = features.trueLabel;
    end
    model.mu = mu;
    model.classifier = classifier;
    
end