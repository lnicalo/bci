function out = AdaptSLDA(features, model)

if nargin == 1
    % Build Adapt LDA model
    % out is the trained model
    
    options = []; % Default options
    
    options.F = 111;
    options.display = 0;
    options.optLevel1.ReguType = 'Ridge';
    options.optLevel1.Regu = true;
    options.optLevel1.ReguAlpha = 115;
    options.optLevel2.ReguType = 'Ridge';
    options.optLevel2.Regu = true;
    options.optLevel2.ReguAlpha = 295;
    options.optLevel2.W = 70;
    % options.optLevel1.CV_K = 100;
    
    % options.time = 110;
    options.adaptParameter = 0.04;
        
    features.data = features.data(:,:,1:options.F);
    out = AdaptSLDAtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptSLDA') ~= 1
        error('Expected model Adapt SLDA not found');
    end
    features.data = features.data(:,:,1:model.options.F);
    
    % out is an struct with predicted labels and scores
    out = AdaptSLDAtest(features, model);
end


end
