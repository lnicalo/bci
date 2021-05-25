function [class, score] = RIMclassify(X,F,classes,L,m)

    net = ALDAlearn(F,classes);
    w_0 = net.w';
    b_0 = net.b;
    
    
    V0 = [w_0 b_0;-w_0 -b_0];
    Nclases = 2;
    options = optimset('GradObj','off','Algorithm','active-set','Display','off','MaxIter',300,'MaxFunEvals',3000);  
    
    N = size(X,1);
    class = NaN(1,N);
    score = NaN(2,N);
    %% Clasificamos las L primeras
    L = 1;
    L_max = N;
    X_L = X(1:L,:);
    b = V0(:,end);
    vb = b(:,ones(size(X_L,1),1));
    w = V0(:,1:end-1);
    score(:,1:L) = w*X_L' + vb;
    [~, class(1,1:L)] = min(score(:,1:L),[],1);
    
    %% Clasificamos las demas actualizando
    for i = L+1:N        
        X_L = X(i-L+1:i,:);
        if i == 21;
            [V,~] = fmincon(@(v) obj_unsuperv(X_L,v,Nclases),V0,[],[],[],[],[],[],@(v) con(v,V0),options);
            b = V(:,end);
            w = V(:,1:end-1);
            normas = sqrt(sum(w.^2,2));
            w = w./normas(:,ones(size(w,2),1));
        end        
        
        vb = b(:,ones(i-1,1));
        score_aux = w*X(1:i-1,:)' + vb;
        [~, class_aux] = min(score_aux,[],1);
        
        diff = sum(class_aux == class(1,1:i-1));
        if diff < (i-1)/2
            % disp(sprintf('Iter: %i. Inv',m))
            w = -w;
            b = -b;
        end
        
        score(:,i) = w*X(i,:)' + b;
        [~, class(1,i)] = min(score(:,i),[],1);
        
        L = L + 1;
        L = min(L,L_max);
    end
    
end
