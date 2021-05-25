function [v, Lparam, L] = paramCV(v1,v2,v3)

switch nargin
    case 1
        v1 = v1(:);
        Lparam = length(v1);
        v = v1;
        L = Lparam;        
    case 2   
        [x(1,:,:),x(2,:,:)] = ndgrid(v1,v2);
        v = reshape(x,[2 numel(x)/2 1])';
        Lparam = [length(v1); length(v2)]; 
        L = prod(Lparam);
    case 3
        [x(1,:,:,:),x(2,:,:,:),x(3,:,:,:)] = ndgrid(v1,v2,v3);
        v = reshape(x,[3 numel(x)/3 1 1])';
        Lparam = [length(v1); length(v2); length(v3)];
        L = prod(Lparam);
end