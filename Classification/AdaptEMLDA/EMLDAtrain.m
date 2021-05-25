function model = EMLDAtrain(training, labels, options)
[n,d] = size(training);
classes = unique(labels);
C = length(classes);
gmeans = NaN(C, d);
for k = 1:C
    gmeans(k,:) = mean(training(labels == k,:),1);
end

% Pooled estimate of covariance.  Do not do pivoting, so that A can be
% computed without unpermuting.  Instead use SVD to find rank of R.
[Q,R] = qr(training - gmeans(labels,:), 0);
R = R / sqrt(n - C); % SigmaHat = R'*R

s = svd(R);

model.C = C;
model.gmeans = gmeans;
model.logDetSigma = 2*sum(log(s)); % avoid over/underflow
model.R = R;
model.options = options;