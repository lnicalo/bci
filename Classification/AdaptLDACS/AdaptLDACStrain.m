function model = AdaptLDACStrain(features, options)

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
    model.ID = 'AdaptLDACS';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    Nsubjects = size(features.dataCS.data, 1);
    model.classifier = cell(Nsubjects, Nsamples);
    model.mu = cell(Nsubjects, Nsamples);
    
    Ntrials  = size(features.data, 1);
    for m = 1:Nsamples
        F = squeeze( features.data(:, m,:) );
        F = reshape( F, Ntrials, [], Nsubjects);
        
        for u = 1:Nsubjects
            Fu = squeeze( F(:, :, u));
            model.mu{u, m} = mean(Fu,1);   
        end
    end
    
    reverseStr = '';
    for u = 1:Nsubjects
        Fu = features.dataCS.data{u, 1};
        labels = features.dataCS.trueLabel{u, 1};
        for m = 1:Nsamples
            F = squeeze( Fu(:, m,:));
            mu = mean(F,1);        
            F = F - repmat(mu, [size(F,1) 1]);
            
            % model.mu{u, m} = mu;
            model.classifier{u, m} = LDAtrain(F, labels, options);
        
            % CV acc
            Ntrials = size(F,1);
            K = 2;
            indices = crossvalind('Kfold', Ntrials, K);
            acc = NaN(K,1);
            
            for i = 1:K
                test = (indices == i); train = ~test;
                modelCV = LDAtrain(F(train,:), labels(1, train), options);
                [acc(i,1), ~, ~] = LDApredict(F(test,:), labels(1, test), modelCV);
            end
            model.classifier{u,m}.acc = mean(acc);
            
            if options.display > 0
                percentDone = 100 * m / Nsubjects;
                msg = sprintf('Training (subject %i): %3.1f\n', u, percentDone);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
    end
end