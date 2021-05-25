function [accuracy, predictlabel, score] = RIMpredict(fea, gnd, model)
    N = size(fea,1);
    K = model.fea*fea';
    
    score = 1./(1+exp(-(model.alphas*K + repmat(model.bs,[1 N]))))';    
    [~, predictlabel] = max(score,[], 2);
    accuracy = mean(predictlabel ~= gnd');
end
