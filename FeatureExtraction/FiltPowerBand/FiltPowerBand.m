% FBCSP
function [extractedFeatures, model] = FiltPowerBand(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = FiltPowerBandtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'FiltPowerBand') ~= 1
        error('Expected model FiltPowerBand not found');
    end
    
    extractedFeatures = FiltPowerBandtest(EEGdata, model);
end


end
