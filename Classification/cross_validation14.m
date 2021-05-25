%% Cross validation
%% Motor imagery - BCI : Train
clear
dataset = 'competIVdatasetIIa1_410foldCV';
extrFeatAlg = 'FBCSP';
featSelAlg = 'MIBIF';
classificationAlg = 'AdaptSLDA';
perfMeas = 'all';
rootPath = '../../02Data/';

inputFiles = dir(sprintf('%s%s/trainFeatures/%s/%s/*.mat', rootPath, dataset, extrFeatAlg, featSelAlg));
Nsubjects = length(inputFiles);

%% CV params - EDIT
% params = {'adaptParameter'}; 
% params = {'F', 'ReguAlpha'};
params = {'ReguAlpha','W'};
% p1 = 0:0.01:0.2;
% p1 = 1:5:72; p2 = 0:10:300;
p1 = 0:20:600; p2 = 5:5:120;
% p1 = 0:50:300; p2 = 5:5:120;

%[CV_param, Lparam, L] = paramCV(p1);
 [CV_param, Lparam, L] = paramCV(p1, p2);

% Variable saving results
performance = cell(L, Nsubjects);
nameSubjects = cell(1, Nsubjects);

% time elased
tstart = tic;

for subject = 1:Nsubjects
    %% Load train features
    nameFile = sprintf('%s%s/trainFeatures/%s/%s/%s', rootPath, dataset, extrFeatAlg, featSelAlg, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'features');
    fprintf('done\n');
    trainFeatures = features;
    
    % Print information features dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Num. Trials: %d\n', size(features.data,1));
    fprintf('- Num. Features: %i\n', size(features.data,3));
    fprintf('----------------------------------\n\n');
    
    %% Load test features
    nameFile = sprintf('%s%s/testFeatures/%s/%s/%s', rootPath, dataset, extrFeatAlg, featSelAlg, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'features');
    fprintf('done\n');
    testFeatures = features;
    clear features
    
    %% Classification param
    parfor i = 1:L    
        %% Options
        options = [];
        options.adaptParameter = 0;
        % options.adaptParameter2 = 0;
        options.F = 71;
        %options.display = 0;
        %options.ReguType = 'Ridge';
        %options.Regu = true;
        % options.ReguAlpha = 300;
        options.optLevel1.ReguType = 'Ridge';
        options.optLevel1.Regu = true;
        options.optLevel1.ReguAlpha = 40;
        options.optLevel2.ReguType = 'Ridge';
        options.optLevel2.Regu = true;
        %options.optLevel2.ReguAlpha = 100;
        %options.optLevel2.W = 55;
        %%
        fprintf('Subj: %i ',subject); 
        for j = 1:size(CV_param, 2)
            % options.(params{1, j}) = CV_param(i, j);      
            options.optLevel2.(params{1, j}) = CV_param(i, j);  
            fprintf('%s: %.2f \t',params{1, j}, CV_param(i, j) );
        end
        fprintf(' --- ');
        
        %% Classification
        if exist(strcat(classificationAlg, '_CV'),'file') ~= 2
            addpath(genpath(classificationAlg));
        end
                
        classificationAlg_ = str2func(strcat(classificationAlg, '_CV'));        
        classificationOut = classificationAlg_(trainFeatures, testFeatures, options);
        
        %% Measure performance
        if exist('perfMeasurement','file') ~= 2
            addpath(genpath('PerfMeasurement'));
        end
        perfSubject = perfMeasurement(classificationOut.labels, testFeatures.trueLabel, perfMeas);
        
        %% Save results
        performance{i, subject} = perfSubject;
    end
    
    nameSubjects{1, subject} = sprintf('%s', inputFiles(subject,1).name);
    fprintf('\n\n');
end

% time elapsed
elapsedTime = toc(tstart);

% ID - identifies feature extraction / feature selection / classification
ID = sprintf('%s_%s_%s', extrFeatAlg, featSelAlg, classificationAlg);
ID = strcat(ID, sprintf('_%s', params{:}));

%% Save
out_dir = sprintf('%s%s/resultsCV/', rootPath, dataset);
if exist(out_dir, 'dir') ~= 7
    mkdir(out_dir);
end
nameFile = sprintf('%s%s.mat', out_dir, ID);
    
fprintf('Saving performance ''%s'' ... ', nameFile);
save(nameFile, 'ID', 'performance', 'nameSubjects', 'CV_param', 'L', 'Lparam', 'elapsedTime')
fprintf('done\n');

fprintf('\n\n')