function [class, score] = ALDAclassify(net,X,eta)

%     [T,N] = size(X);
%     
%     b = net.b;
%     w = net.w;
%     
%     M = [b, w'];
%     V = [ones(1,T);X'];
%     
%     % Actualizamos la media
%     mu = net.mu;   
%     
%     mu_t = mu;
%     for i = 1:T
%         x = X(i,:);
%         mu_t = (1 - eta)*mu_t + eta*(x);
%         b_t = -w'*mu_t';
%         
%         M = [b_t, w'];
%         V = [1;x'];
%         score(i,:) = M*V;
%         
%     end
%     
%     class = 2*(score > 0) + 1*(score <= 0);
[T,N] = size(X);
    
    b = net.b;
    w = net.w;
    
    % Actualizamos la media
    mu = net.mu;   
    sigma = net.sigma;
    
    mu1 = net.mu1;
    mu2 = net.mu2;
    
    mu_t(1,:) = mu;
    for i = 1:T
        x = X(i,:);
        mu_t(i+1,:) = (1 - eta)*mu_t(i,:) + eta*(x);
%         mu1 = (1 - eta)*mu1 + eta*(x);
%         mu2 = (1 - eta)*mu2 + eta*(x);
        
        b_t = -w'*mu_t(i+1,:)';
        
        M = [b_t, w'];
        V = [1;x'];
        D(i,:) = M*V;
        
        delta1 = 1/((2*pi)^(N/2)*det(sigma)^(0.5))*exp(-1/2*((x - mu1)'\sigma)*(x - mu1)');
        delta2 = 1/((2*pi)^(N/2)*det(sigma)^(0.5))*exp(-1/2*((x - mu2)'\sigma)*(x - mu2)');
        score(i,:) = delta1/(delta1 + delta2);
        
        mu1_t(i,:) = mu1;
        mu2_t(i,:) = mu2;
        delta1_t(i,:) = delta1;
        delta2_t(i,:) = delta2;
    end
    class = 2*(D > 0) + 1*(D <= 0);
end
