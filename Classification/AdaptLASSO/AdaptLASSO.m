function out = AdaptLASSO(features, model)
% features.data = features.data(:,:,1:36);
if nargin == 1
    % Build Adapt LASSO model
    % out is the trained model
    
    options = []; % Default options
    options.F = 50;
    features.data = features.data(:,:,1:options.F);
    out = AdaptLASSOtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptLASSO') ~= 1
        error('Expected model Adapt LASSO not found');
    end
    
    % out is an struct with predicted labels and scores
    features.data = features.data(:,:,1:model.options.F);
    out = AdaptLASSOtest(features, model);
end


end
