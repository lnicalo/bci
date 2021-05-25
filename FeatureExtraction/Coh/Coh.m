% FBCSP
function [extractedFeatures, model] = Coh(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = Cohtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'Coh') ~= 1
        error('Expected model Coh not found');
    end
    
    extractedFeatures = Cohtest(EEGdata, model);
end


end
