function out = AdaptEMLDA_CV(trainFeatures, testFeatures, options)

% Select first F features
if isfield( options, 'F')
    trainFeatures.data = trainFeatures.data(:,:,1:options.F);
    testFeatures.data  = testFeatures.data(:,:,1:options.F);
end

model = AdaptEMLDAtrain(trainFeatures, options);
out = AdaptEMLDAtest(testFeatures, model);

end
