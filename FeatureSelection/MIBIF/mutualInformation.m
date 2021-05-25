function mi=mutualInformation(x,y,p)
%% cálculo de la informacion mutua mediante el metodo de Parzen
% x = puntos de la variable aleatoria continua
% y = clases
% p = probabilidad a priori de las clases
%%  
    
    y = y(:);
    clases = unique(y);
    nc = numel(clases);
    
    if nargin < 3
        p = NaN(1, nc);
        for i = 1:nc
            p(1,i) = mean(y == clases(i,1));
        end
    end
    p = p(:)'; % p vector fila
    x = x(:);
    N = size(x,1);
    
    % Probabilidad p(x|y)
    p_x_c = NaN(nc,N);
    for i = 1:nc
        p_x_c(i,:) = parzen(x,x(y(:,1) == clases(i,1),1));
    end
    
    % Probabilidad p(y|x) - Aplicando Regla de Bayes
    p_c_fij = NaN(nc,N);
    den = p*p_x_c;
    for i = 1:nc
        p_c_fij(i,:) = p(i)*p_x_c(i,:)./den;
    end
    
    % Entropia H(y|x)
    a = p_c_fij.*log2(p_c_fij);
    H_c_x  = -nansum(a(:))/N;
    
    % Entropia H(y)
    H_w = -p*log2(p)';
    mi = H_w - H_c_x;
 end
