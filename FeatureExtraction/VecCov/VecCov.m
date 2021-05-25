% FBCSP
function [extractedFeatures, model] = VecCov(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = VecCovtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'VecCov') ~= 1
        error('Expected model VecCov not found');
    end
    
    extractedFeatures = VecCovtest(EEGdata, model);
end


end
