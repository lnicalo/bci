function [accuracy, predictlabel, score] = EMLDApredict(fea, gnd, model)
N = size(fea, 1);
C = model.C;
Nss = model.options.semisupervised;
if Nss == 0
    [predictlabel, score] = expectation(model, fea);
    
    accuracy = mean(predictlabel ~= gnd');
else
    predictlabel = NaN(N,1);
    score = NaN(N,C);
    [predictlabel(1:Nss), score(1:Nss,:)] = expectation(model, fea(1:Nss,:));
    
    for k = Nss+1:N          
        model = maximization(fea(1:k-1,:),score(1:k-1,:));
        [predictlabel(k,:), score(k,:)] = expectation(model, fea(k,:));        
    end
    
    accuracy = mean(predictlabel ~= gnd');
end

end

function [outclass, posterior] = expectation(model,sample)
    C = model.C;
    N = size(sample,1);
    D = NaN(N, C);
    
    % MVN relative log posterior density, by group, for each sample
    for k = 1:C
        A = bsxfun(@minus,sample, model.gmeans(k,:)) / model.R;
        D(:,k) = log(1/C) - .5*(sum(A .* A, 2) + model.logDetSigma);
    end
    
    [maxD,outclass] = max(D, [], 2);
        
    % Bayes' rule: first compute p{x,G_j} = p{x|G_j}Pr{G_j} ...
    % (scaled by max(p{x,G_j}) to avoid over/underflow)
    P = exp(bsxfun(@minus,D,maxD));
    sumP = nansum(P,2);
    % ... then Pr{G_j|x) = p(x,G_j} / sum(p(x,G_j}) ...
    % (numer and denom are both scaled, so it cancels out)
    posterior = bsxfun(@times,P,1./(sumP));
end


function model = maximization(samples,posterior)
D = size(samples,2);
[N C] = size(posterior);
p = sum(posterior,1)/N;
gmeans = NaN(C,D);

for i = 1:C
    gmeans(i,:) = 1/N*sum(bsxfun(@times, samples, posterior(:,i)))/p(1,i);
end
model.gmeans = gmeans;

% Pooled estimate of covariance.
aux = NaN(D,N,C);
for i = 1:C
    aux(:,:,i) = bsxfun(@times,samples - ones(N,1)*gmeans(i,:),sqrt(posterior(:,i)))';
end
aux = aux(:,:);

[R,~] = qr(aux, 0);
R = R / sqrt(N - C); % SigmaHat = R'*R
s = svd(R);

% Store data
model.gmeans = gmeans;
model.logDetSigma = 2*sum(log(s)); % avoid over/underflow
model.R = R;
model.C = C;
end
