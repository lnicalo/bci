function out = AdaptEMLDA(features, model)

if nargin == 1
    % Build Expectation - Maximization LDA model
    % out is the trained model
    
    options = []; % Default options
    options.F = 41;
    options.display = 0;
    % options.time = 67;
    options.semisupervised = 50;
    options.adaptParameter = 0.0;
    features.data = features.data(:,:,1:options.F);
    
    out = AdaptEMLDAtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptEMLDA') ~= 1
        error('Expected model AdaptEMLDA not found');
    end
    
    % out is an struct with predicted labels and scores
    features.data = features.data(:,:,1:model.options.F);
    out = AdaptEMLDAtest(features, model);
end


end
