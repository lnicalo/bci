% FBCSP
function [extractedFeatures, model] = CSFBCSP(EEGdata, EEGdataCS, model)

if nargin == 2
    % Build FBCSP model
    
    options = []; % Default options
    options.artifactSelection = true;
    options.tempFilter = [];
    % options.tempFilter.freqBands = [4 30];
    [ extractedFeatures, model ] = CSFBCSPtrain(EEGdata, EEGdataCS, options);
elseif nargin == 3
    % Check model
    if strcmp(model.ID,'CSFBCSP') ~= 1
        error('Expected model CSBCSP not found');
    end
    
    extractedFeatures = CSFBCSPtest(EEGdata, model);
end


end
