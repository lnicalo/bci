function [accuracy, predictlabel, score] = adaptMLDApredict(fea, gnd, model, beta, equal)
nTrials = size(fea,1);
nClass = model.nClass;
nFeats = size(fea, 2);

PairWiseClassC  = model.PairWiseClassC;
w       = model.PairWiseW;
b       = model.PairWiseB;

score = NaN(nTrials, nClass);
predictlabel = NaN(nTrials, 1);
for trial = 1:nTrials
    x = fea(trial,:);
    % Discriminant function
    D = [b w] * [1; x'];
    
    % Probability
    Q = 1 ./ (1 + exp(-D));
    
    P = NaN(nClass, 1);
    for j = 1:nClass
        P(j, :) = sum(Q((nClass-1)*(j-1)+1:(nClass-1)*j,:),1)./sum(Q);
    end
    
    % Predict label
    [~, predictlabel(trial,1)] = max(P);
    score(trial, :) = P';
    
    % Update
    % Gamma coefficients
    cont = 1;
    gamma = ones(nClass * (nClass - 1), 1) / nClass;
    if ~equal        
        for i = 1:nClass
            for j = setdiff(1:nClass,i)
                gamma(cont,1) = P(i,1) + P(j,1);
                cont = cont + 1;
            end
        end
    end
    
    gamma = repmat(gamma, [1 nFeats]);
    
    % Update pairwise centers
    PairWiseClassC = (1 - gamma.*beta) .* PairWiseClassC + gamma * beta .* repmat(x, nClass * (nClass - 1),1);
    PairWiseClassC = (1 - gamma) .* PairWiseClassC * trial / (trial + 1) + ...
        gamma .* repmat(x, nClass * (nClass - 1),1) / (trial + 1);
    
    
    % Update pairwise bias
    cont = 1;
    for i = 1:nClass
        for j = setdiff(1:nClass,i)
            % PairWiseW(cont,:) = squeeze(PairWiseC(cont,:,:)) \ (ClassCenter(j,:) - ClassCenter(i,:))';
            b(cont,:) = -w(cont,:) * PairWiseClassC(cont,:)';
            cont = cont + 1;
        end
    end
end

accuracy = mean(predictlabel == gnd');

end