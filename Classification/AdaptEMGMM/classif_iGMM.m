function [out_classif, scores] = classif_iGMM(features,at,classes,Nhi)
    at = permute(at,[3 1 2]);
    [Ntrials,~,Nsamples] = size(at);
    features = permute(features,[3 1 2]);
    
    % Reserva de memoria    
    scores = NaN(Ntrials,Nsamples,length(unique(classes)));
    out_classif = NaN(Ntrials,Nsamples);
    parfor m = 1:Nsamples  
        F = features(:,:,m);
        X = at(:,:,m);
        
        iGMMmodel = trainGMM(F,classes);  
        [out_classif(:,m),scores(:,m,:)] = predict_iGMM(X,iGMMmodel,Nhi);
    end
end