function f = featuresCSP(scms,W)
    Ntrials = size(scms,1);

    f = [];
    for j = 1:Ntrials % intentos de cada sesion    
        aux = W'*(squeeze(scms(j,:,:))*W);
        aux = log(diag(aux)/trace(aux));
        f = cat(1,f,aux');
    end % Trials  
end