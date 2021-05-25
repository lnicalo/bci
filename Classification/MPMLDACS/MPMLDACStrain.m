function model = MPMLDACStrain(features, options)

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
    model.ID = 'MPMLDACS';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    Nsubjects = size(features.dataCS.data, 1);
    model.classifier = cell(Nsubjects, Nsamples);
    model.mu = cell(Nsubjects, Nsamples);
    
    reverseStr = '';
    for u = 1:Nsubjects
        Fu = features.dataCS.data{u, 1};
        labels = features.dataCS.trueLabel{u, 1};
        for m = 1:Nsamples
            F = squeeze( Fu(:, m,:));
            mu = mean(F,1);        
            F = F - repmat(mu, [size(F,1) 1]);
            
            model.mu{u, m} = mu;
            model.classifier{u, m} = MLDAtrain(F, labels, options);
                                   
            if options.display > 0
                percentDone = 100 * m / Nsamples;
                msg = sprintf('Training (subject %i): %3.1f\n', u, percentDone);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
    end
end