function model = AdaptSLDAtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'optLevel1')
        % Reguralization
        options.optLevel1 = [];
    end
    
    if ~isfield(options,'optLevel2')
        % Reguralization
        options.optLevel2 = [];
    end
    
    if ~isfield(options,'adaptParameter')
        % Adaptive parameter
        options.adaptParameter = 0.05;
    end
        
    % Options level 1
    if ~isfield(options.optLevel1,'Regu')
        
        % Reguralization
        options.optLevel1.Regu = true;
    end
    
    if ~isfield(options.optLevel1,'ReguAlpha')
        % Reguralization
        options.optLevel1.ReguAlpha = 85;
    end
    
    if ~isfield(options.optLevel1,'ReguType')
        % Reguralization
        options.optLevel1.ReguType = 'Ridge';
    end
    
    if ~isfield(options.optLevel1,'CV_K')
        % Reguralization
        options.optLevel1.CV_K = 1;
    end

    % Options level 2
    if ~isfield(options.optLevel2,'Regu')
        % Reguralization
        options.optLevel2.Regu = true;
    end
    
    if ~isfield(options.optLevel2,'ReguAlpha')
        % Reguralization
        options.optLevel2.ReguAlpha = 155;
    end
    
    if ~isfield(options.optLevel2,'ReguType')
        % Reguralization
        options.optLevel2.ReguType = 'Ridge';
    end
    
    if ~isfield(options.optLevel2,'W')
        % Reguralization
        options.optLevel2.W = 50;
    end   
    
    
    model = [];
    model.ID = 'AdaptSLDA';
    model.options = options;    
    
    % Training
    Nsamples = size(features.data, 2);
    Ntrain   = size(features.data, 1);
    Nclasses = length(unique(features.trueLabel));
    
    modelLDA1 = cell(1, Nsamples);
    mu = cell(1, Nsamples); 
    
    train_scores = NaN(Nsamples, Ntrain, Nclasses - 1);
    
    %% Stacked generalization
    %% Level - 0
    optLevel1 = options.optLevel1;
    data = features.data;
    trueLabel = features.trueLabel;
    
    parfor m = 1:Nsamples
        F = squeeze( data(:, m, :) );
        mu_aux = mean( F, 1);
        F = F - repmat(mu_aux, [Ntrain 1]);
        
        mu{1, m} = mu_aux;
        
        % CV data for Level - 1
        K = options.optLevel1.CV_K;
        if  K > 1
            indices = crossvalind('Kfold', Ntrain, K);
            v = NaN(Ntrain, Nclasses - 1);
            for i = 1:K
                test = (indices == i); train = ~test;
                modelCV = LDAtrain(F(train,:), trueLabel(1, train), optLevel1);
                v(test,:) = F(test,:) * modelCV.eigvector;
            end
            
            train_scores(m,:,:) = v;
            model_aux = LDAtrain(F, trueLabel, optLevel1);
            modelLDA1{1, m} = model_aux;
        else
            model_aux = LDAtrain(F, trueLabel, optLevel1);
            train_scores(m,:,:) = F * model_aux.eigvector;
            modelLDA1{1, m} = model_aux;
        end
        
        % Trained model on training data
        
    end
    
    model.modelLDA1 = modelLDA1;
    model.mu = mu;
    
    %% Level - 1
    optLevel2 = options.optLevel2;
    train_scores = permute( train_scores, [2 1 3]);
    modelLDA2 = cell(1, Nsamples);
    parfor m = 1:Nsamples
        train_scores_m = train_scores( :, ...
            max( m - optLevel2.W + 1,1) : m, :);
        train_scores_m = train_scores_m(:,:);
        
        modelLDA2{1, m} = LDAtrain(train_scores_m, trueLabel, optLevel2);
    end
    model.modelLDA2 = modelLDA2;
end