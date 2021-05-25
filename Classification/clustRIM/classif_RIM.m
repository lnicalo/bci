function [out_classif score] = classif_RIM(features,at,classes,m_ini,eta)
    Nsamples = size(features,1);
    Ntrials  = size(at{1,1},2);
    Nclasses = length(unique(classes));
    scores = NaN(Nsamples,Ntrials);
    out_classif = NaN(Ntrials,Nsamples);
    for m = 70
        init_model = [];
        if rem(m,30)==0, fprintf('Iteracion: %i\n',m+m_ini-1); end
        F = features{m,1}';
        X = at{m,1}';
        mu = mean(F,1);
        F = F - repmat(mu,[size(F,1) 1]);
        
        % Clasificacion
        L = 200;
        U = 20;
        XF = [F(end-L+1:end,:); X];
        global test_classes;
        
        classesXF = [classes(1,end-L+1:end)'; test_classes];
        
        N_FX = Ntrials + L;
        init_model.alphas = randn(Nclasses,L);
        init_model.bs = zeros(Nclasses,1);%randn(params.max_class,1);
        
        class_aux = NaN(N_FX,1);
        score_aux = NaN(N_FX,1);
        v = 1:L;
        X_L = XF(v,:);
        global classesXF_L;
        classesXF_L = classesXF(v,:);
        class_aux(v,1) = RIMclassify(X_L,F,classes);
        
        
        for i = U:U:N_FX-L
            v = i:(i+L-1);
            nuevos = U+L-length(v);
            X_L = XF(v,:);
            classesXF_L = classesXF(v,:);
            % model.alphas = circshift(model.alphas,[0 nuevos]);
            % model.alphas(:,end-nuevos+1:end) = 0;
            class_aux(v,1) = RIMclassify(X_L,F,classes);
            class_aux(v,1) = RIMclassify(X_L,F,classes);
            disp(i)
        end
        
        % Classificamos el final
        N = N_FX-v(1,end);
        if N > 0
            v = v + N;
            X_L = XF(v,:);
            model.alphas = circshift(model.alphas,[1 N]);
            model.alphas(:,end-N+1:end) = 0;
            [class_aux(v,1), score_aux(v,1), model] = RIMclassify(X_L,F,classes,model);   
        end
        
        out_classif(:,m) = class_aux(L+1:end,1);
        score(m,:) = score_aux(L+1:end,1);
    end
end