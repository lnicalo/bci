function out = MPMLDACS(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    % options.time = 59;
    options.adaptParameter = 0.0;
    out = MPMLDACStrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'MPMLDACS') ~= 1
        error('Expected model MPMLDA not found');
    end
    
    % out is an struct with predicted labels and scores
    out = MPMLDACStest(features, model);
end


end
