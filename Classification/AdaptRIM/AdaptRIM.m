function out = AdaptRIM(features, model)
features.data = features.data(:,:,1:85);
if nargin == 1
    % Build Adapt RIM model
    % out is the trained model
    
    options = []; % Default options
    out = AdaptRIMtrain(features, options);
    
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'AdaptRIM') ~= 1
        error('Expected model Adapt RIM not found');
    end
    
    % out is an struct with predicted labels and scores
    out = AdaptRIMtest(features, model);
end


end
