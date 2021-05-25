function out = AdaptGFK(features, model)
features.data = features.data(:,:,1:2:end);
if nargin == 1
    % Build AdaptGFK model
    
    options = []; % Default options
    out = AdaptGFKtrain(features, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptGFK') ~= 1
        error('Expected model AdaptGFK not found');
    end
    
    out = AdaptGFKtest(features, model);
end


end
