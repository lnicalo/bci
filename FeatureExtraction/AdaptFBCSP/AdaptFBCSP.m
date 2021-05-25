% FBCSP
function [extractedFeatures, model] = AdaptFBCSP(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = AdaptFBCSPtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptFBCSP') ~= 1
        error('Expected model AdaptFBCSP not found');
    end
    
    extractedFeatures = AdaptFBCSPtest(EEGdata, model);
end


end
