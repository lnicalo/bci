function [acc, out, scores] = SSSRKDApredict( features, gnd, model )

options = model.options;
% Number of test and train trials
Ntest = size(features, 1);
Ntrain = size(model.gnd, 2);

% Construct kernel 
features = [model.fea; features];
K = constructKernel(features, [], options);

% Training labels and tentative predicted labels
labels = [model.gnd zeros(1, Ntest)];
labels_n = labels;

% Posterior probability for train and test samples
post = [2*ones(1,Ntrain) zeros(1,Ntest)];
post_n = post;

% Predicted labels 
out = NaN(1,Ntest);

% Threshold - test trials with posterior probability below th are discarded
th = options.th;

ii = 1;
fprintf('     ');
acc_h = cell(Ntest,1);
for i = Ntrain+1 : (Ntrain + Ntest)
    t = tic;
    [labels_n(1, Ntrain+1:i), post_n(1, Ntrain+1:i)] = SRKDApredict_(K(Ntrain+1:i, post > th), model);
    
    it = 0;
    acc = [];
    acc(1,1) = mean(labels(1, Ntrain+1:i) == gnd(1:i-Ntrain));
    while ( ~isequal(post_n > th, post > th) || ...
            ~isequal(labels_n(post_n > th), labels(post_n > th)) ) && it < 15
        post = post_n;
        labels = labels_n;
        model = SRKDAtrain_(K(post > th,post > th), labels(1, post > th), options);
        
        [labels_n(1, Ntrain+1:i), post_n(1,Ntrain+1:i)] = SRKDApredict_(K(Ntrain+1:i, post > th), model);
        it = it + 1;
        acc(it+1,1) = mean(labels(1, Ntrain+1:i) == gnd(1:i-Ntrain));
    end
    
    post = post_n;
    labels = labels_n;
    model = SRKDAtrain_(K(post > th, post > th), labels(1, post > th), options);
    out(1, i - Ntrain) = labels_n(1, i); 
    acc(it+2,1) = mean(labels(1, Ntrain+1:i) == gnd(1:i-Ntrain));
    acc_h{i - Ntrain,1} = acc;
    l_h(i-Ntrain,1) = length(acc);
    d_acc(i-Ntrain,1) = acc(end,1) - acc(1,1);
    tiempo(ii,1) = toc(t);
    ii = ii + 1;
    fprintf('\b\b\b\b\b%05i',ii);
end

acc = 1 - length(find(out - gnd))/Ntest;
scores = post(Ntrain+1:end);

end

function [model] = SRKDAtrain_(K, gnd, options)

nSmp = size(K,1);

ClassLabel = unique(gnd);
model.ClassLabel = ClassLabel;
nClass = length(ClassLabel);

% Response Generation
rand('state',0);
Y = rand(nClass,nClass);
Z = zeros(nSmp,nClass);
for i=1:nClass
    idx = find(gnd==ClassLabel(i));
    Z(idx,:) = repmat(Y(i,:),length(idx),1);
end
Z(:,1) = ones(nSmp,1);
[Y,R] = qr(Z,0);
Y(:,1) = [];

model.bSemi = 0;

[model.projection , ~] = KSR(options, Y, K);
    
Embed_Train = K*model.projection;


ClassCenter = zeros(nClass,size(Embed_Train,2));
for i = 1:nClass
    feaTmp = Embed_Train(gnd == ClassLabel(i),:);
    ClassCenter(i,:) = mean(feaTmp,1);
end
model.ClassCenter = ClassCenter;

model.TYPE = 'SRKDA';
model.options = options;

end


function [predictlabel,post] = SRKDApredict_(K, model)
if ~strcmp(model.TYPE,'SRKDA')
    error('model does not match!');
end

Embed_Test = K*model.projection;
D = EuDist2(Embed_Test,model.ClassCenter,0);
[dump, idx] = min(D,[],2);
predictlabel = model.ClassLabel(idx);

Ds = sort(D,2,'ascend');
diff = Ds(:,1) - Ds(:,2);
post = 1./(1 + exp(diff'));
end







