function model = LDAtrain(fea, gnd, options)
    [eigvector, eigvalue] = LDA(fea, gnd, options);
    model.eigvector = eigvector;
    model.eigvalue  = eigvalue;
    
    ClassLabel = unique(gnd);
    model.ClassLabel = ClassLabel;
    nClass = length(ClassLabel);
    
    projection = fea * eigvector;
    ClassCenter = zeros(nClass, size(projection, 2));
    for i = 1:nClass
        ClassCenter(i,:) = mean(projection(gnd == ClassLabel(i),:), 1);
    end
    model.ClassCenter = ClassCenter;
end