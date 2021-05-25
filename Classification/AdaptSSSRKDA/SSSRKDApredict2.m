function [acc, out, scores] = SSSRKDApredict2( features, gnd, model )

options = model.options;
% Number of test and train trials
Ntest = size(features, 1);
Ntrain = size(model.gnd, 2);
ClassLabel = unique(model.gnd);
Nclasses = length(ClassLabel);

% Construct kernel 
features = [model.fea; features];
K = constructKernel(features, [], options);

% Regularization
K(1:size(K,1)+1:end) = K(1:size(K,1)+1:end) + options.ReguAlpha;
        
% Training labels and tentative predicted labels
labels = [model.gnd zeros(1, Ntest)];
labels_n = labels;

% Predicted labels 
out = NaN(1,Ntest);  

% 
RK = chol(K);
for i = Ntrain+1 : (Ntrain + Ntest)
    % Predict next test sample   
    K_test = K(i, 1:i-1);  
    [labels_n(1, i), ~] = SRKDApredict_(K_test, model);
    
    it = 0;
    % Enlarge train dataset
    K_train = K(1:i, 1:i);
    
    % Cholesky factorization
    R = RK(1:i, 1:i);
    
    % Test dataset
    K_test = K(i, 1:i);
    
    while ~isequal(labels_n, labels) && it < 20
        labels = labels_n;
        labels_train = labels_n(1, 1:i);
        
        %% Update
        % Re-train
        Responses = responseGeneration(labels_train);
        model.projection = R \ (R'\Responses);
        
        Embed_Train = K_train * model.projection;
        ClassCenter = zeros(Nclasses, size(Embed_Train, 2));
        for j = 1:Nclasses
            feaTmp = Embed_Train(labels_train == ClassLabel(j),:);
            ClassCenter(j,:) = mean(feaTmp, 1);
        end
        model.ClassCenter = ClassCenter;
        
        %% Predict test samples
        [labels_n(1, i), ~] = SRKDApredict_(K_test, model);
        
        %% Iteration
        it = it + 1;
    end
    
    %% Final update
    labels_train = labels_n(1, 1:i);
    
    % Re-train
    Responses = responseGeneration(labels_train);
    model.projection = R \ (R'\Responses);
    
    Embed_Train = K_train * model.projection;
    ClassCenter = zeros(Nclasses, size(Embed_Train, 2));
    for j = 1:Nclasses
        feaTmp = Embed_Train(labels_train == ClassLabel(j),:);
        ClassCenter(j,:) = mean(feaTmp, 1);
    end
    model.ClassCenter = ClassCenter;
        
    out(1, i - Ntrain) = labels_n(1, i);
end

acc = 1 - length(find(out - gnd)) / Ntest;
scores = NaN(Ntest, 1);

end


function Y = responseGeneration(gnd)
    nSmp = length(gnd);

    ClassLabel = unique(gnd);
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







