% FBCSP
function [extractedFeatures, model] = CSFBCSPU(EEGdata, EEGdataCS, model)

if nargin == 2
    % Build FBCSP model
    
    options = []; % Default options
    options.artifactSelection = true;
    options.tempFilter = [];
    options.adapt = true;
    % options.tempFilter.freqBands = [4 8;8 12;12 16;16 20;20 24;24 28;28 32;32 36;36 40];
    
    [ extractedFeatures, model ] = CSFBCSPUtrain(EEGdata, EEGdataCS, options);
elseif nargin == 3
    % Check model
    if strcmp(model.ID,'CSFBCSPU') ~= 1
        error('Expected model CSBCSPU not found');
    end
    
    extractedFeatures = CSFBCSPUtest(EEGdata, model);
end


end
