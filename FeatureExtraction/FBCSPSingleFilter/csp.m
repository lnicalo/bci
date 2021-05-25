function W = csp(scm_1, scm_2, m)
    % Calcula de la matriz de covarianza media
    % Suponiendo geometria euclidea
    C1_mean = squeeze( mean(scm_1, 1) );
    C2_mean = squeeze( mean(scm_2, 1) );

    [W, D] = eig(C1_mean, C1_mean+C2_mean, 'qz');
    [~, ind] = sort(diag(D), 'descend');
    W = W(:, ind([1:m, (end-m+1):end], 1));
end