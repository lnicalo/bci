%% Motor imagery - BCI
%% Performance Summary
rootPath = '../../02Data/';
dataset = 'competIVdatasetIIa1_2';
measure = 'acc';
fig_number = 1;
decimals = 2; % Number of decimals

extrFeatAlg = 'FBCSP';
featSelAlg = '';
classificationAlg = '';
options = '';
inputFiles = dir(sprintf('%s%s/results/*%s*%s*%s*%s*.mat', ...
    rootPath, dataset, extrFeatAlg, featSelAlg, classificationAlg, options));

Nmodels = length(inputFiles);

dataset_mean_perf = [];
dataset_max_perf = [];
method_labels = cell(1, Nmodels);
dataset_max_mean_perf = NaN(1, Nmodels);
for model = 1:Nmodels
    % Load model results
    nameFile = sprintf('%s%s/results/%s', rootPath, dataset, inputFiles(model,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'performance', 'ID', 'nameSubjects');
    fprintf('done\n');
    fprintf('Loaded %s model results\n', ID);
    
    Nsubjects = length(performance);

    % Mean performance 
    mean_perf = 0;
    
    % Max performance for each subject
    max_perf = NaN(Nsubjects, 1);
    
    for subject = 1:Nsubjects
        perf = performance{1, subject};        
        subject_perf = abs( perf.(measure) );
        
        mean_perf = mean_perf + subject_perf;
        max_perf(subject, 1) = max(subject_perf);
    end
    mean_perf = mean_perf / Nsubjects;
    
    dataset_max_perf = cat(2, dataset_max_perf, max_perf);
    dataset_max_mean_perf(1, model) = max(mean_perf);
    
    method_labels{1, model} = ID;
end
dataset_max_mean_max_perf = mean(dataset_max_perf, 1);
dataset_max_std_max_perf = std(dataset_max_perf, 1, 1);

%% Show dataset performnce - Table format
subject_labels = sprintf('%s ',nameSubjects{1,:});
subject_labels = strrep(subject_labels, '.mat', '');
subject_labels = [subject_labels 'MEAN' ' ' 'SD' ' ' 'MEAN2'];
subject_labels = regexp(subject_labels,' ','split');

aux = round(10^decimals*[dataset_max_perf; dataset_max_mean_max_perf; dataset_max_std_max_perf; dataset_max_mean_perf])/10^decimals;
dataset_perf = mat2dataset ( aux );
dataset_perf.Properties.ObsNames = subject_labels;
dataset_perf.Properties.VarNames = method_labels;

disp_performance = strrep(evalc('disp(dataset_perf)'), '_', ':');
disp(disp_performance)