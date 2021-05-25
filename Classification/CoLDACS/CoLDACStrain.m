function model = CoLDACStrain(features, options)

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
    model.ID = 'CoLDACS';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    Nsubjects = size(features.dataCS.data, 1);
    model.classifier = cell(Nsubjects, Nsamples);
    
    % Train H0
    reverseStr = '';
    for u = 1:Nsubjects
        Fu = features.dataCS.data{u, 1};
        labels = features.dataCS.trueLabel{u, 1};
        for m = 1:Nsamples
            F = squeeze( Fu(:, m,:));
            mu = mean(F,1);        
            model.mu{u, m} = mu;
            F = F - repmat(mu, [size(F,1) 1]);
            model.classifier{u, m} = MLDAtrain(F, labels, options);
                                   
            if options.display > 0
                percentDone = 100 * m / Nsamples;
                msg = sprintf('Training (subject %i): %3.1f\n', u, percentDone);
                fprintf([reverseStr, msg]);
                reverseStr = repmat(sprintf('\b'), 1, length(msg));
            end
        end
    end
    
    Ntrials = size(features.data,1);
    Nclasses  = length( model.classifier{1,1}.ClassLabel );
    scores = NaN(Ntrials, Nclasses, Nsubjects);
    
    trueLabel = features.trueLabel;
    classifierH0 = model.classifier;
    
    % Prediction   
    reverseStr = '';
    for m = 1:Nsamples
        X = squeeze( features.data(:, m,:) );
        X = reshape( X, Ntrials, [], Nsubjects);
        
        ii = 1;
        while(1)
            classifierH_aux = classifierH0;
            for u_tg = 1:Nsubjects
                for u_sr = setdiff(1:Nsubjects, u_tg)
                    Fu_sr = squeeze( X(:,:,u_sr) );
                    mu = mean(Fu_sr,1);
                    Fu_sr = Fu_sr - repmat(mu, [size(Fu_sr,1) 1]);
                    
                    % LDA classification
                    [~, ~, scores(:, :, u_sr)] = MLDApredict(Fu_sr, trueLabel, classifierH0{u_sr, m});
                end
                
                scores = squeeze(nanmean(scores, 3));
                [~, labels_unsup] = max(scores, [], 2);
                
                Fu = features.dataCS.data{u_tg, 1};
                labels = features.dataCS.trueLabel{u_tg, 1};
                F = squeeze( Fu(:, m,:));
                mu = mean(F,1);
                F = F - repmat(mu, [size(F,1) 1]);
                
                Fu_tg = squeeze( X(:,:,u_tg) );
                mu = mean(Fu_tg,1);
                Fu_tg = Fu_tg - repmat(mu, [size(Fu_tg,1) 1]);
                
                F = [Fu_tg];
                labels = [labels_unsup'];
                classifierH_aux{u, m} = MLDAtrain(F, labels, options);
                
                acc(u_tg,ii) = mean(labels_unsup == trueLabel');
                
            end
            
            if ii > 1
                diff = abs(acc(:,ii-1) - acc(:,ii));
                if sum(diff(:)) < 10^-4
                    break;
                end
            end
            ii = ii + 1;
            classifierH0 = classifierH_aux;
        end
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Training: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
    model.classifier = classifierH0;
end