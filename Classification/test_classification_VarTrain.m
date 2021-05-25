%% Classification
%% Motor imagery - BCI : Classification test
clear

dataset = 'competIVdatasetIIa1_2';
extrFeatAlg = 'FBCSP';
featSelAlg = 'none';
classificationFolder = 'AdaptSLDA';
perfMeas = 'all';
trainRatio = 25;

rootPath = '../../02Data/';

inputFiles = dir(sprintf('%s%s/testFeaturesVT/%sTR%02i/%s/*.mat', rootPath, dataset, extrFeatAlg, trainRatio, featSelAlg));
Nsubjects = length(inputFiles);

% Variable saving results
performance = cell(1,Nsubjects);

for subject = 1:Nsubjects
    %% Load features
    nameFile = sprintf('%s%s/testFeaturesVT/%sTR%02i/%s/%s', rootPath, dataset, extrFeatAlg, trainRatio, featSelAlg, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'features');
    fprintf('done\n');
    
    % Print information features dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Num. Trials: %d\n', size(features.data,1));
    fprintf('- Num. Features: %i\n', size(features.data,3));
    fprintf('----------------------------------\n\n');
    
    %% Load trained classification model    
    nameFile = sprintf('%s%s/trainFeaturesVT/%sTR%02i/%s/%s/%s', rootPath, dataset, extrFeatAlg, trainRatio, ...
        featSelAlg, classificationFolder, inputFiles(subject,1).name);
    load(nameFile,'model');
    
    %% Classification  
    classificationAlg = model.ID;
    if exist(classificationAlg,'file') ~= 2
        addpath(genpath(classificationAlg));
    end
    
    classificationAlg_ = str2func(classificationAlg);
    classificationOut = classificationAlg_(features, model);
    
    %% Measure performance
    if exist('perfMeasurement','file') ~= 2
        addpath(genpath('PerfMeasurement'));
    end    
    perfSubject = perfMeasurement(classificationOut.labels, features.trueLabel, perfMeas);
    
    %% Save results
    performance{1, subject} = perfSubject;    
end
% ID - identifies feature extraction / feature selection / classification
ID = sprintf('%s_%s_%s', extrFeatAlg, featSelAlg, classificationAlg);

%% Save
out_dir = sprintf('%s%s/resultsVT/', rootPath, dataset);
if exist(out_dir, 'dir') ~= 7
    mkdir(out_dir);
end
nameFile = sprintf('%s%s.mat', out_dir, ID);
    
fprintf('Saving performance ''%s'' ... ', nameFile);
save(nameFile, 'ID', 'performance')
fprintf('done\n');

fprintf('\n\n')

perfSummaryBCIComp_VarTrain