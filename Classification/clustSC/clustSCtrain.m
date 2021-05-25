function model = clustSCtrain(features, options)

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
    model.ID = 'clustSC';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    model.classifier = cell(1, Nsamples);
    model.mu = cell(1, Nsamples);
    model.classLabel = unique(features.trueLabel);
    reverseStr = '';
    for m = 1:Nsamples
        F = squeeze( features.data(:, m,:) );
        mu = mean(F,1);        
        F = F - repmat(mu, [size(F,1) 1]);
        
        model.mu{1, m} = mu;
        model.classifier{1, m} = SCtrain(F, features.trueLabel, options);   
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Training: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
end