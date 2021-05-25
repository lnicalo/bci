%% Feature selection
%% Motor imagery - BCI : Train
clear

dataset = 'competIVdatasetIIa';
extrFeatAlg = 'FBCSP';
featSelFolder = 'MIBIF';

rootPath = '../../02Data/';

inputFiles = dir(sprintf('%s%s/testFeatures/%s/none/*.mat', rootPath, dataset, extrFeatAlg));
Nsubjects = length(inputFiles);

for subject = 1:Nsubjects
    %% Load features
    nameFile = sprintf('%s%s/testFeatures/%s/none/%s', rootPath, dataset, extrFeatAlg, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'features');
    fprintf('done\n');
    
    % Print information features dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Num. Trials: %d\n', size(features.data,1));
    fprintf('- Num. Features: %i\n', size(features.data,3));
    fprintf('----------------------------------\n\n');
    
    %% Load trained selection model
    namefile = sprintf('%s%s/trainFeatures/%s/%s/%s', rootPath, dataset, extrFeatAlg, featSelFolder, inputFiles(subject,1).name);
    load(namefile,'model');
    
    %% Feature Selection    
    featSelAlg = model.ID;
    if exist(featSelAlg,'file') ~= 2
        addpath(genpath(featSelAlg));
    end
    
    featSelAlg_ = str2func(featSelAlg);
    [features, model] = featSelAlg_(features, model);
    
    %% Save
    out_dir = sprintf('%s%s/testFeatures/%s/%s', rootPath, dataset, extrFeatAlg, featSelFolder);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    namefile = sprintf('%s/%s', out_dir, inputFiles(subject,1).name);
    
    fprintf('Saving features and model ''%s'' ... ', namefile);
    save(namefile,'subject','features','model')
    fprintf('done\n');
    
    fprintf('\n\n')
end