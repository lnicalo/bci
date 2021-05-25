% FBCSP
function [extractedFeatures, model] = FBCSP(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    options.artifactSelection = true;
    options.tempFilter = [];
    % options.tempFilter.freqBands = [4 30];
    [ extractedFeatures, model ] = FBCSPtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'FBCSP') ~= 1
        error('Expected model FBCSP not found');
    end
    
    extractedFeatures = FBCSPtest(EEGdata, model);
end


end
