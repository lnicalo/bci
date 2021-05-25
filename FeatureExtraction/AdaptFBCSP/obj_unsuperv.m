function [L] = obj_unsuperv(scms,w)
    f = featuresCSP(scms,w);
    L = loss(f');  
end
