function model = AdaptLDAtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'Regu')
        % Reguralization
        options.Regu = false;
    end
    
    if ~isfield(options,'ReguAlpha')
        % Regularization Parameter
        options.ReguAlpha = 0;
    end
    
    if ~isfield(options,'ReguType')
        % Regularization Type
        options.ReguType = 'Ridge';
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
    model.ID = 'AdaptLDA';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    model.modelLDA = cell(1, Nsamples);
    model.mu = cell(1, Nsamples);
    
    reverseStr = '';
    for m = 1:Nsamples
        F = squeeze( features.data(:, m,:) );
        mu = mean(F,1);        
        F = F - repmat(mu, [size(F,1) 1]);
        
        model.mu{1, m} = mu;
        model.modelLDA{1, m} = LDAtrain(F, features.trueLabel, options);   
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Training: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
end