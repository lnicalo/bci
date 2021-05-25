function out = AdaptEMGMM(features, model)

if nargin == 1
    % Build Expectation - Maximization LDA model
    % out is the trained model
    
    options = []; % Default options
    options.F = 50;
    options.display = 1;
    % options.time = 67;
    options.semisupervised = 0;
    options.adaptParameter = 0.0;
    features.data = features.data(:,:,1:options.F);
    
    out = AdaptEMGMMtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptEMGMM') ~= 1
        error('Expected model AdaptEMGMM not found');
    end
    
    % out is an struct with predicted labels and scores
    features.data = features.data(:,:,1:model.options.F);
    out = AdaptEMGMMtest(features, model);
end


end
