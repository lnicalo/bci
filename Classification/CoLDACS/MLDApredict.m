function [accuracy, predictlabel, score] = MLDApredict(fea, gnd, model)
    nTrials = size(fea,1);
    nClass = model.nClass;

    w       = model.PairWiseW;
    b       = model.PairWiseB;

    D = [b w] * [ones(1, nTrials); fea'];

    % Probability
    Q = 1 ./ (1 + exp(-D));

    P = NaN(nClass, nTrials);
    for j = 1:nClass
        P(j, :) = sum(Q((nClass-1)*(j-1)+1:(nClass-1)*j,:),1)./sum(Q);
    end

    % Predict label
    P = P';
    [~, predictlabel] = max(P,[],2);
    score = P;

    accuracy = mean(predictlabel == gnd');
end