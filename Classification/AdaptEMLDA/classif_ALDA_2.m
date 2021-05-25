function [out_classif score] = classif_ALDA_2(features,at,classes,m_ini,eta)
 % fprintf('Clasificacion: Parzen Probabilistic Neural Network\n');
    at = permute(at,[3 1 2]);
    [Ntrials,Nfeatures,Nsamples] = size(at);
    
    features = permute(features,[3 1 2]);    
    
    % Reserva de memoria
    out_classif = NaN(size(at,1),Nsamples-m_ini+1);
    score = NaN(size(at,1),Nsamples-m_ini+1);
    
    % fprintf('Num. iteraciones: %i\n',Nsamples);
    
    for m = 1:Nsamples-m_ini+1
        % if rem(m,30)==0, fprintf('Iteracion: %i\n',m+m_ini-1); end
        
        % Clasificacion
        mu = mean(features(:,:,m+m_ini-1),1);
        X_train = features(:,:,m+m_ini-1) - repmat(mu,[size(features,1) 1]);
        
        X = NaN(Ntrials,Nfeatures);
        for trial = 1:Ntrials;
            aux = at(trial,:,m+m_ini-1);
            mu = (1-eta)*mu + eta*aux;
            X(trial,:) = aux - mu;
        end
        
        
        % Clasificacion
        [out_classif(:,m),~,aux] = classify(X,X_train,classes);
        score(:,m) = aux(:,1);
    end
end