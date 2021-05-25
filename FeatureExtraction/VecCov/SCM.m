function SCMs = SCM(s)
    N = size(s,1);
    L = size(s,2);
    C = size(s,3);
    % Calculo de las matrices de covarianza
    SCMs = NaN(N,C,C);
    for i = 1:N
        s_i = squeeze(s(i,:,:));
        aux = s_i'*s_i;
        SCMs(i,:,:) = aux/trace(aux);
    end
end