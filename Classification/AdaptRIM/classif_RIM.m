function [out_classif score] = classif_RIM(features,at,classes,m_ini,eta)
 % fprintf('Clasificacion: Parzen Probabilistic Neural Network\n');
    at = permute(at,[3 1 2]);
    [Ntrials,Nfeatures,Nsamples] = size(at);
    features = permute(features,[3 1 2]);
    
    Nclasses = 2;
    % fprintf('Num. iteraciones: %i\n',Nsamples);
    parfor m = 1:Nsamples
        if rem(m,30)==0, fprintf('Iteracion: %i\n',m+m_ini-1); end
        test_features = at;
        train_features = features;
        X = test_features(:,:,m+m_ini-1);
        F = train_features(:,:,m-m_ini+1);
        
        L = 20;
        [out_classif(:,m),aux] = RIMclassify(X,F,classes,L,m);
        score(m,:,:) = aux';
    
    end
end