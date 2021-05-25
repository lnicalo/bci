function out = KernelUMLDA(features, model)
if nargin == 1
    % Build KernelUMLDA model
    
    options = []; % Default options
    out = KernelUMLDAtrain(features, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'KernelUMLDA') ~= 1
        error('Expected model Kernel UMLDA not found');
    end
    
    out = KernelUMLDAtest(features, model);
end


end
