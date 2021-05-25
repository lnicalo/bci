function out = AdaptLDA(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    options.F = 144;
    options.display = 0;
    options.ReguType = 'Ridge';
    options.Regu = true;
    options.ReguAlpha = 90;
    % options.time = 67;
    options.adaptParameter = 0.0;
    features.data = features.data(:,:,1:options.F);
    
    out = AdaptLDAtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptLDA') ~= 1
        error('Expected model Adapt LDA not found');
    end
    
    % out is an struct with predicted labels and scores
    features.data = features.data(:,:,1:model.options.F);
    out = AdaptLDAtest(features, model);
end


end
