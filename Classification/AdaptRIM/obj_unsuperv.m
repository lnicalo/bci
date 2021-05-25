function [L] = obj_unsuperv(X,v,n_classes)
    b = v(:,end);
    w = v(:,1:end-1);

    b = b(:,ones(size(X,1),1));
    f = w*X' + b;
    L = loss(f,n_classes);    
end
