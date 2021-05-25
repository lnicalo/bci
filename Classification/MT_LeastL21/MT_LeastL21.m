function out = MT_LeastL21(features, model)

if nargin == 1
    % Build Adapt LDA model
    options = [];
    out = MT_LeastL21train(features, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'MT_LeastL21') ~= 1
        error('Expected model MT_LeastL21 not found');
    end
    
    out = MT_LeastL21test(features, model);
end


end
