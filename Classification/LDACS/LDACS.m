function out = AdaptLDACS(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    options.display = 0;
    options.ReguType = 'Ridge';
    options.Regu = true;
    options.ReguAlpha = 0;
    % options.time = 67;
    options.adaptParameter = 0.0;
    
    out = AdaptLDACStrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptLDACS') ~= 1
        error('Expected model Adapt LDACS not found');
    end
    
    % out is an struct with predicted labels and scores
    out = AdaptLDACStest(features, model);
end


end
