function [out_classif, post, acc] = classif_EM_ALDA(features,at,classes,param)
    at = permute(at,[3 1 2]);
    [Ntrials,~,Nsamples] = size(at);
    features = permute(features,[3 1 2]);
    
    % Reserva de memoria    
    scores = NaN(Ntrials,Nsamples,length(unique(classes)));
    out_classif = NaN(Ntrials,Nsamples);
    parfor m = 1:Nsamples  
        F = features(:,:,m);
        X = at(:,:,m);
        
        % Clasificacion              
        net = EM_ALDAlearn(F,classes);
        [out_classif(:,m),aux] = EM_ALDAclassify(net,X,param);   
        post(:,m) = aux(:,2);
    end   
    
    acc = [];
end