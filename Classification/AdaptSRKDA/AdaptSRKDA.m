function out = AdaptSRKDA(features, model)

if nargin == 1
    % Build Adapt SRKDA model
    
    options = []; % Default options
    options.F = 97;
    options.adaptParameter = 0.1;
    options.KernelType = 'Linear';
    options.ReguAlpha = 85;
    features.data = features.data(:,:,1:options.F);
    out = AdaptSRKDAtrain(features, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptSRKDA') ~= 1
        error('Expected model Adapt SRKDA not found');
    end
    features.data = features.data(:,:,1:model.options.F);
    out = AdaptSRKDAtest(features, model);
end


end
