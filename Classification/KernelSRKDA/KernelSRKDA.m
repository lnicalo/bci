function out = KernelSRKDA(features, model)
if nargin == 1
    % Build Adapt SRKDA model
    
    options = []; % Default options
    out = KernelSRKDAtrain(features, options);
elseif nargin == 2
    % Check model
    if strcmp(model.ID,'KernelSRKDA') ~= 1
        error('Expected model Kernel SRKDA not found');
    end
    
    out = KernelSRKDAtest(features, model);
end


end
