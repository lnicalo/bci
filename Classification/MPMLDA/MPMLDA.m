function out = MPMLDA(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    options.F = 72;
    % options.time = 59;
    options.adaptParameter1 = 0.0;
    options.adaptParameter2 = 0.0;
    options.equal = 0;
    
    features.data = features.data(:,:,1:options.F);
    out = MPMLDAtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'MPMLDA') ~= 1
        error('Expected model MPMLDA not found');
    end
    
    % out is an struct with predicted labels and scores
    features.data = features.data(:,:,1:model.options.F);
    out = MPMLDAtest(features, model);
end


end
