function model = AdaptGFKtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'adaptParameter')
        % Adaptive parameter
        options.adaptParameter = 0.05;
    end
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 1;
    end
    
    model = [];
    model.ID = 'AdaptGFK';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    model.classifier = cell(1, Nsamples);
    model.mu = cell(1, Nsamples);    
    for m = 1:Nsamples
        F = squeeze( features.data(:, m,:) );
        mu = mean(F,1);        
        F = F - repmat(mu, [size(F,1) 1]);
        
        model.mu{1, m} = mu;
        model.classifier{1, m}.Ps = princomp(F);    
        model.classifier{1, m}.F  = F;
        
    end
    model.labels = features.trueLabel;
end