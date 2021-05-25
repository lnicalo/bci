% FBCSP
function [extractedFeatures, model] = CSFBCSPUE(EEGdata, EEGdataCS, model)

if nargin == 2
    % Build FBCSP model
    
    options = []; % Default options
    options.artifactSelection = true;
    options.tempFilter = [];
    options.adapt = true;
    % options.tempFilter.freqBands = [4 8;8 12;12 16;16 20;20 24;24 28;28 32;32 36;36 40];
    
    [ extractedFeatures, model ] = CSFBCSPUEtrain(EEGdata, EEGdataCS, options);
elseif nargin == 3
    % Check model
    if strcmp(model.ID,'CSFBCSPUE') ~= 1
        error('Expected model CSBCSPUE not found');
    end
    
    extractedFeatures = CSFBCSPUEtest(EEGdata, model);
end


end
