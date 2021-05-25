% FBCSP
function [extractedFeatures, model] = PowerBand(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = PowerBandtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'PowerBand') ~= 1
        error('Expected model Coh not found');
    end
    
    extractedFeatures = PowerBandtest(EEGdata, model);
end


end
