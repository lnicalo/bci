% FBCSP
function [extractedFeatures, model] = PCSFBCSP(EEGdata, EEGdataCS, model)

if nargin == 2
    % Build FBCSP model
    
    options = []; % Default options
    options.artifactSelection = true;
    options.tempFilter = [];
    % options.tempFilter.freqBands = [4 30];
    [ extractedFeatures, model ] = PCSFBCSPtrain(EEGdata, EEGdataCS, options);
elseif nargin == 3
    % Check model
    if strcmp(model.ID,'PCSFBCSP') ~= 1
        error('Expected model CSBCSP not found');
    end
    
    extractedFeatures = PCSFBCSPtest(EEGdata, model);
end


end
