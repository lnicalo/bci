% FBCSP
function [extractedFeatures, model] = FBCSPSingleFilter(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = FBCSPSingleFiltertrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'FBCSPSingleFilter') ~= 1
        error('Expected model FBCSPSingleFilter not found');
    end
    
    extractedFeatures = FBCSPSingleFiltertest(EEGdata, model);
end


end
