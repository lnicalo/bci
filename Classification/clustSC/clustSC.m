function out = clustSC(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    % options.time = 59;
    options.display = 1;
    options.adaptParameter = 0.0;
    out = clustSCtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'clustSC') ~= 1
        error('Expected model clustSC not found');
    end
    
    % out is an struct with predicted labels and scores
    out = clustSCtest(features, model);
end


end
