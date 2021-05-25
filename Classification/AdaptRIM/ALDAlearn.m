function net = ALDAlearn(samples,classification)
    % Samples Trials x Features
    % classification = Trials x 1
    x1 = samples(classification == 1,:);
    x2 = samples(classification == 2,:);
    
    N1 = size(x1,1);
    N2 = size(x2,1);
    
    mu1 = mean(x1,1);
    mu2 = mean(x2,1);
    
   
    sigma = cov(samples,1);
%     v_ = trace(sigma)/size(sigma,1);
%     gamma_ = 0.5;
%     sigma = (1- gamma_)*sigma + gamma_*v_*eye(size(sigma,1));
    
    mu = 1/2*(mu1 + mu2);
    net.mu = mu;
    
    mu_d = mu2 - mu1;
    
    net.w = mu_d'\sigma;
    net.w = net.w';
    net.b = -net.w'*mu';
    
    net.sigma = sigma;
    net.mu1 = mu1;
    net.mu2 = mu2;    
end