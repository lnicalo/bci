function [features, model] = MIBIFtrain(features, options)

model = [];
model.ID = 'MIBIF';

if ~exist('options', 'var')
    options = [];
end

if ~isfield(options,'dispaly')
    % display information
    options.display = 1;
end

if ~isfield(options,'nFeatures')
    % return all features
    options.nFeatures = size(features.data,3);
end

model.options = options;

Nfeatures  = size(features.data,3);
Ntime = size(features.data,2);

%% Computing mutual information
I = NaN(Nfeatures,Ntime);

% reverseStr = '';
parfor i = 1:Nfeatures
    a = squeeze(features.data(:,:,i));
    aux = NaN(1, Ntime);
    for j = 1:Ntime
        aux(1,j) = mutualInformation(a(:,j), features.trueLabel);
    end
    I(i,:) = aux;
    
%     if options.display > 0
%         percentDone = 100 * i / Nfeatures;
%         msg = sprintf('Computing mutual information: %3.1f\n', percentDone);
%         fprintf([reverseStr, msg]);
%         reerseStr = repmat(sprintf('\b'), 1, length(msg));
%     end
end

model.I = I;

%% Sorting features
[~, ind] = sort(I,1,'descend');
model.selection = ind;
Ntrials = size(features.data,1);

sel_features = NaN(Ntrials, Ntime, options.nFeatures);

for i = 1:Ntime
    sel_features(:,i,:) = features.data(:, i, ind(1:options.nFeatures,i));
end

features.data = sel_features;

end
