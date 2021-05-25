function model = EMGMMtrain(X, classes, options)
classes = classes(:);
c = unique(classes);
C = length(c);

N = size(X,1);
M = size(X,2);
mu = NaN(M,C);
Sigma = NaN(M,M,C);
w = NaN(1,C);
for i = 1:C
    Xc = X(classes == c(i,1),:);
    Nk = size(Xc,1);
    mu(:,i) = mean(Xc);
    
    Sigma(:,:,i) = cov(Xc,1);
    % Xc = bsxfun(@minus,X',mu(:,i));
    % Sigma(:,:,i) = 1/Nk*(Xc*Xc'); % + eye(M)*(1e-6); % add a prior for numerical stability;
    w(1,i) = Nk/N;
end

aux = squeeze(sum(Sigma,3));
for i = 1:C
    Sigma(:,:,i) = aux;
end

model = [];
model.mu = mu;
model.Sigma = Sigma;
model.weight = w;
model.options = options;
end