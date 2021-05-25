%% Classification
%% Motor imagery - BCI : Classification test
clear

dataset = 'competIVdatasetIIa';
extrFeatAlg = 'CSFBCSP';
featSelAlg = 'none';
classificationFolder = 'AdaptLDA';
perfMeas = 'all';

rootPath = '../../02Data/';

inputFiles = dir(sprintf('%s%s/testFeatures/%s/%s/*.mat', rootPath, dataset, extrFeatAlg, featSelAlg));
Nsubjects = length(inputFiles);

%% Trained models
inputTrainFiles = dir(sprintf('%s%s/trainFeatures/%s/%s/*.mat', rootPath, dataset, extrFeatAlg, featSelAlg));
Ntrainsubjects = length(inputTrainFiles);

%% Variable saving results
performance = cell(1, Nsubjects * Ntrainsubjects);
NameSubjects = cell(1, Nsubjects * Ntrainsubjects);
subject_aux = 1;
for subject = 1:Nsubjects
    %% Load features
    nameFile = sprintf('%s%s/testFeatures/%s/%s/%s', rootPath, dataset, extrFeatAlg, featSelAlg, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'features');
    fprintf('done\n');
    
    % Print information features dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Num. Trials: %d\n', size(features.data,1));
    fprintf('- Num. Features: %i\n', size(features.data,3));
    fprintf('----------------------------------\n\n');
    
    
    
    for trainSubject = 1:Ntrainsubjects
        %% Load trained model
        nameFile = sprintf('%s%s/trainFeatures/%s/%s/%s/%s', rootPath, dataset, extrFeatAlg, featSelAlg, classificationFolder, inputTrainFiles(trainSubject,1).name);
        fprintf('Loading training model ''%s'' ... ', nameFile);
        load(nameFile,'model');
        fprintf('done\n');
            
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
        performance{1, subject_aux} = perfSubject;
        NameSubjects{1, subject_aux} = sprintf('%s_%s', inputFiles(subject,1).name, inputTrainFiles(trainSubject,1).name);
        
        subject_aux = subject_aux + 1;        
    end 
end
% ID - identifies feature extraction / feature selection / classification
ID = sprintf('%s_%s_%s', extrFeatAlg, featSelAlg, classificationAlg);
%% Save
out_dir = sprintf('%s%s/resultsCS/', rootPath, dataset);
if exist(out_dir, 'dir') ~= 7
    mkdir(out_dir);
end
nameFile = sprintf('%s%s.mat', out_dir, ID);
    
fprintf('Saving performance ''%s'' ... ', nameFile);
save(nameFile, 'ID', 'NameSubjects', 'performance')
fprintf('done\n');

fprintf('\n\n')

perfSummary_CrossSubj_BCIComp