% FBCSP
function [extractedFeatures, model] = FBCSPFilt(EEGdata, model)

if nargin == 1
    % Build FBCSP model
    
    options = []; % Default options
    [ extractedFeatures, model ] = FBCSPFilttrain(EEGdata, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'FBCSPFilt') ~= 1
        error('Expected model FBCSPFilt not found');
    end
    
    extractedFeatures = FBCSPFilttest(EEGdata, model);
end


end
