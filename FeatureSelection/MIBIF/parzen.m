function out = parzen(x,data)
    % Calcula la funcion de una VA en los puntos x dando como datos data
    
    % Hacemos x vector columna
    x = x(:);
    data = data(:);
    
    % Tamano de x
    N = size(x,1);
    M = size(data,1);
    
    % out es un vector del mismo tamano que x
    out = NaN(N,1);   
    
    % Metodo de Parzen
    % Calculamos el h optimo
    sigma = std(data);
    h = (4/(3*M))^(1/5)*sigma;
       
    dif = repmat(x,[1 M]) - repmat(data',[N 1]);
    phi = 1/(sqrt(2*pi)*h*size(dif,2))*exp(-dif.^2/(2*h^2));
    out = sum(phi,2);  
end
