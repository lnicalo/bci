%% Classification
%% Motor imagery - BCI : Train
clear
dataset = 'competIVdatasetIIa1_2';
extrFeatAlg = 'FBCSP';
featSelAlg = 'none';
classificationAlg = 'AdaptSLDA';
trainRatio = 25;

rootPath = '../../02Data/';

inputFiles = dir(sprintf('%s%s/trainFeaturesVT/%sTR%02i/%s/*.mat', rootPath, dataset, extrFeatAlg, trainRatio, featSelAlg));
Nsubjects = length(inputFiles);

for subject = 1:Nsubjects
    %% Load features
    nameFile = sprintf('%s%s/trainFeaturesVT/%sTR%02i/%s/%s', rootPath, dataset, extrFeatAlg, trainRatio, featSelAlg, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'features');
    fprintf('done\n');
    
    % Print information features dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Num. Trials: %d\n', size(features.data,1));
    fprintf('- Num. Features: %i\n', size(features.data,3));
    fprintf('----------------------------------\n\n');
    
    %% Classification   
    if exist(classificationAlg,'file') ~= 2
        addpath(genpath(classificationAlg));
    end
    
    classificationAlg_ = str2func(classificationAlg);
    model = classificationAlg_(features);
    
    %% Save
    out_dir = sprintf('%s%s/trainFeaturesVT/%sTR%02i/%s/%s', rootPath, dataset, extrFeatAlg, trainRatio, featSelAlg, classificationAlg);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    nameFile = sprintf('%s/%s', out_dir, inputFiles(subject,1).name);
    
    fprintf('Saving %s : ''%s'' ... ', model.ID, nameFile);
    save(nameFile, 'subject', 'model')
    fprintf('done\n');
    
    fprintf('\n\n');
end