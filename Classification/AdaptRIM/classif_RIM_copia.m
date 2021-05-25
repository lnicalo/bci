function [out_classif, score] = classif_RIM_copia(features,at,classes,m_ini,eta)
    at = permute(at,[3 1 2]);
    [Ntrials,Nfeatures,Nsamples] = size(at);
    features = permute(features,[3 1 2]);
    
    Nclasses = 2;
    % fprintf('Num. iteraciones: %i\n',Nsamples);
    out_classif = NaN(Ntrials,Nsamples);
    score = NaN(Ntrials,Nsamples);
    parfor m = 1:Nsamples-m_ini+1
        init_model = [];
        if rem(m,30)==0, fprintf('Iteracion: %i\n',m+m_ini-1); end
        
        aux = squeeze(features(:,:,m));
        mu = mean(aux,1);
        F =  aux - repmat(mu,[size(aux,1) 1]);
        
        X = squeeze(at(:,:,m+m_ini-1));
        
        % Clasificacion
        L = 50;
        U = 2;
        XF = [F(end-L+1:end,:); X];
        N_FX = Ntrials + L;
        init_model.alphas = randn(Nclasses,L);
        init_model.bs = zeros(Nclasses,1);%randn(params.max_class,1);
        
        class_aux = NaN(N_FX,1);
        score_aux = NaN(N_FX,1);
        v = 1:L;
        X_L = XF(v,:);
        [class_aux(v,1), score_aux(v,1), model] = RIMclassify_copia(X_L,F,classes,init_model);
        
        
        for i = U:U:N_FX-L
            v = i:(i+L-1);
            nuevos = U+L-length(v);
            X_L = XF(v,:);
            model.alphas = circshift(model.alphas,[1 nuevos]);
            model.alphas(:,end-nuevos+1:end) = 0;
            [class_aux(v,1), score_aux(v,1), model] = RIMclassify_copia(X_L,F,classes,model);             
        end
        
        % Classificamos el final
        N = N_FX-v(1,end);
        if N > 0
            v = v + N;
            X_L = XF(v,:);
            model.alphas = circshift(model.alphas,[1 N]);
            model.alphas(:,end-N+1:end) = 0;
            [class_aux(v,1), score_aux(v,1), model] = RIMclassify_copia(X_L,F,classes,model);   
        end
        
        out_classif(:,m) = class_aux(L+1:end,1);
        score(:,m) = score_aux(L+1:end,1);
    end
end