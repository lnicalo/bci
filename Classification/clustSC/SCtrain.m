function model = SCtrain(fea, gnd, options)
     
    A = fea * fea';
    model.fea = fea;
    % D = diag(1/sqrt(sum(A,2)));
    % L = A - D * A * D;
    
    k = 1;
    [V, ~] = eigs(A, k);
    model.u = median(V);
    model.p = V;   
    model.accuracy = SCpredict(fea, gnd, model);
end
