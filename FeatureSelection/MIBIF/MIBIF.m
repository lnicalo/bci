% MIBIF
function [features, model] = MIBIF(features, model)

if nargin == 1
    % Build MIBIF model
    
    options = []; % Default options
    [ features, model ] = MIBIFtrain(features, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'MIBIF') ~= 1
        error('Expected model MIBIF not found');
    end
    
    features = MIBIFtest(features, model);
end


end
