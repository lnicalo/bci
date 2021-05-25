function out = CoLDACS(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    % options.time = 59;
    options.adaptParameter = 0.05;
    out = CoLDACStrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'CoLDACS') ~= 1
        error('Expected model CoLDACS not found');
    end
    
    % out is an struct with predicted labels and scores
    out = CoLDACStest(features, model);
end


end
