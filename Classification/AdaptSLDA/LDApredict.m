function [accuracy, predictlabel, D] = LDApredict(fea, gnd, model)
    projection = fea*model.eigvector;
        
    D = EuDist2(projection,model.ClassCenter,0);
    [dump, idx] = min(D,[],2);
    predictlabel = model.ClassLabel(idx);
    
    nTest = length(gnd);
    accuracy = 1 - length(find(predictlabel-gnd))/nTest;
end