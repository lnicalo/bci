% FBCSP
function [extractedFeatures, model] = SpecCSP(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = SpecCSPtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'SpecCSP') ~= 1
        error('Expected model SpecCSP not found');
    end
    
    extractedFeatures = SpecCSPtest(EEGdata, model);
end


end
