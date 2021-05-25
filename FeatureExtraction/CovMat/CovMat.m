% FBCSP
function [extractedFeatures, model] = CovMat(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = CovMattrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'CovMat') ~= 1
        error('Expected model CovMat not found');
    end
    
    extractedFeatures = CovMattest(EEGdata, model);
end


end
