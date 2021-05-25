% FBCSP
function [extractedFeatures, model] = DSAFBCSP(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    options.artifactSelection = true;
    options.tempFilter = [];
    %options.tempFilter.freqBands = [4 30];
    [ extractedFeatures, model ] = DSAFBCSPtrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'DSAFBCSP') ~= 1
        error('Expected model DSAFBCSP not found');
    end
    
    extractedFeatures = DSAFBCSPtest(EEGdata, model);
end


end
