function model = MLDAtrain(fea, gnd, options)
    ClassLabel = unique(gnd);
    model.ClassLabel = ClassLabel;
    nClass = length(ClassLabel);
    model.nClass = nClass;
    
    %% Normalize
    % fea = normr(fea);
    
    %% Class centers
    ClassCenter = zeros(nClass, size(fea, 2));
    for i = 1:nClass
        ClassCenter(i,:) = mean(fea(gnd == ClassLabel(i),:), 1);
    end    
    
    %% Class covariances
    ClassC = zeros(nClass, size(fea, 2), size(fea, 2));
    for i = 1:nClass
        C = cov(fea(gnd == ClassLabel(i),:), 1);
        % D = diag(1./sqrt(diag(C)));
        % C = D * C * D;
        ClassC(i,:,:) = C;
    end
    
    %% Pair-wise covariances
    PairWiseC = zeros(nClass * (nClass - 1) * 0.5, size(fea, 2), size(fea, 2));
    cont = 1;
    for i = 1:nClass
        for j = setdiff(1:nClass,i)
            PairWiseC(cont, :,:) = 0.5 * (ClassC(i,:,:) + ClassC(j,:,:));
            cont = cont + 1;
        end
    end
    
    %% Pair-wise class centers
    PairWiseClassC = zeros(nClass * (nClass - 1) * 0.5, size(fea, 2));
    cont = 1;
    for i = 1:nClass
        for j = setdiff(1:nClass,i)
            PairWiseClassC(cont,:) = 0.5 * (ClassCenter(i,:) + ClassCenter(j,:));
            cont = cont + 1;
        end
    end
    model.PairWiseClassC = PairWiseClassC;
    
    %% Pair-wise vector of weights
    PairWiseW = zeros(nClass * (nClass - 1) * 0.5, size(fea, 2));
    PairWiseB = zeros(nClass * (nClass - 1) * 0.5, 1);
    cont = 1;
    for i = 1:nClass
        for j = setdiff(1:nClass,i)
            % PairWiseW(cont,:) = squeeze(PairWiseC(cont,:,:)) \ (ClassCenter(j,:) - ClassCenter(i,:))';
            PairWiseW(cont,:) = (ClassCenter(i,:) - ClassCenter(j,:));
            PairWiseB(cont,:) = -PairWiseW(cont,:) * PairWiseClassC(cont,:)';
            cont = cont + 1;
        end
    end    
    model.PairWiseW = PairWiseW;
    model.PairWiseB = PairWiseB;
    
    
end