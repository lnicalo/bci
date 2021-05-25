function out = MPMLDA_CV(trainFeatures, testFeatures, options)

% Select first F features
if isfield( options, 'F')
    trainFeatures.data = trainFeatures.data(:,:,1:options.F);
    testFeatures.data  = testFeatures.data(:,:,1:options.F);
end

model = MPMLDAtrain(trainFeatures, options);
out = MPMLDAtest(testFeatures, model);

end
