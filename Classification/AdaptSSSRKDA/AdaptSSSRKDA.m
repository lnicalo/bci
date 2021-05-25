function out = AdaptSSSRKDA(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    options.F = 97;
    options.semiSupervised = true;
    features.data = features.data(:,:,1:options.F);
    options.adaptParameter = 0.0;
    options.ReguAlpha = 85;
    out = AdaptSSSRKDAtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptSSSRKDA') ~= 1
        error('Expected model Adapt SS-SRKDA not found');
    end
    features.data = features.data(:,:,1:model.options.F);
    
    % out is an struct with predicted labels and scores
    out = AdaptSSSRKDAtest(features, model);
end


end
