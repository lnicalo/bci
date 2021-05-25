function [class, score] = ALDAclassify_2(net,X,eta)
[T,N] = size(X);
    
    b = net.b;
    w = net.w;
    
    % Actualizamos la media       
    sigma = net.sigma;
    mu = net.mu;
    mu1 = net.mu1;
    mu2 = net.mu2;
    
    M = 40;
    class = NaN(T,1);
    score = NaN(T,1);
    for i = 1:T
        x = X(i,:);
        
        p_x_1 = 1/((2*pi)^(N/2)*det(sigma)^(0.5))*exp(-1/2*((x - mu1)'\sigma)*(x - mu1)');
        p_x_2 = 1/((2*pi)^(N/2)*det(sigma)^(0.5))*exp(-1/2*((x - mu2)'\sigma)*(x - mu2)');
        p_1_x(i,:) = p_x_1/(p_x_1 + p_x_2);
        p_2_x(i,:) = p_x_2/(p_x_1 + p_x_2);
        
        if (i>=M)
        v = i:-1:max(i-M,1);
        L = length(v);
        mu1 = 1/(0.5*L)*sum(repmat(p_1_x(v,:),[1 N]).*X(v,:),1);
        mu2 = 1/(0.5*L)*sum(repmat(p_2_x(v,:),[1 N]).*X(v,:),1);
        end
%         c1 = X(v,:) - repmat(mu1,[L 1]);
%         c2 = X(v,:) - repmat(mu2,[L 1]);
%         
%         aux1 = NaN(L,N,N);
%         aux2 = NaN(L,N,N);
%         for j=1:L
%             aux1(j,:,:) = p_1_x(j,1)*c1(j,:)'*c1(j,:);
%             aux2(j,:,:) = p_2_x(j,1)*c2(j,:)'*c2(j,:);
%         end
%         
%         C1 = squeeze(sum(aux1,1));
%         C2 = squeeze(sum(aux2,1));
%         % sigma = 1/(L-1)*(C1+C2);
%         end
        class(i,1) = 1*(p_1_x(i,1) > p_2_x(i,1)) + 2*(p_2_x(i,1) >= p_1_x(i,1));
        score(i,1) = p_1_x(i,1);
%         
        a1(i,:) = mu1;
        a2(i,:) = mu2;
    end
    
end
