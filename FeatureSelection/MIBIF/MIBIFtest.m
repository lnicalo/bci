function [features, model] = MIBIFtest(features, model)


options = model.options;

Nfeatures = options.nFeatures;
Ntime = size(features.data,2);

%% Sorting features
ind = model.selection;
Ntrials = size(features.data,1);

sel_features = NaN(Ntrials, Ntime, options.nFeatures);

for i = 1:Ntime
    sel_features(:,i,:) = features.data(:, i, ind(1:Nfeatures,i));
end

features.data = sel_features;

end
