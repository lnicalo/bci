function out = MT_CMTL(features, model)

if nargin == 1
    % Build Adapt LDA model
    options = [];
    out = MT_CMTLtrain(features, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'MT_CMTL') ~= 1
        error('Expected model MT_CMTL not found');
    end
    
    out = MT_CMTLtest(features, model);
end


end
