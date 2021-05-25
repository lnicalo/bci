%% Motor imagery - BCI
%% Performance Summary
rootPath = '../../02Data/';
dataset = 'competIVdatasetIIa1_2';
measure = 'kappa';
fig_number = 1;
decimals = 3; % Number of decimals

inputFiles = dir(sprintf('%s%s/resultsVT/*.mat', rootPath, dataset));

Nmodels = length(inputFiles);

dataset_mean_perf = [];
dataset_max_perf = [];
method_labels = cell(1, Nmodels);
dataset_max_mean_perf = NaN(1, Nmodels);
for model = 1:Nmodels
    % Load model results
    nameFile = sprintf('%s%s/resultsVT/%s', rootPath, dataset, inputFiles(model,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'performance', 'ID');
    fprintf('done\n');
    fprintf('Loaded %s model results\n', ID);
    
    Nsubjects = length(performance);

    % Mean performance 
    mean_perf = 0;
    
    % Max performance for each subject
    max_perf = NaN(Nsubjects, 1);
    
    for subject = 1:Nsubjects
        perf = performance{1, subject};        
        subject_perf = perf.(measure);
        
        mean_perf = mean_perf + subject_perf;
        max_perf(subject, 1) = max(subject_perf);
    end
    mean_perf = mean_perf / Nsubjects;
    
    dataset_max_perf = cat(2, dataset_max_perf, max_perf);
    dataset_max_mean_perf(1, model) = max(mean_perf);
    
    method_labels{1, model} = ID;
end
dataset_max_mean_max_perf = mean(dataset_max_perf, 1);

%% Show dataset performnce - Table format
subject_labels = sprintf('S%i ',1:Nsubjects);
subject_labels = [subject_labels 'MEAN' ' ' 'MEAN2'];
subject_labels = strsplit(subject_labels);

aux = round(10^decimals*[dataset_max_perf; dataset_max_mean_max_perf; dataset_max_mean_perf])/10^decimals;
dataset_perf = mat2dataset ( aux );
dataset_perf.Properties.ObsNames = subject_labels;
dataset_perf.Properties.VarNames = method_labels;

disp_performance = strrep(evalc('disp(dataset_perf)'), '_', ':');
disp(disp_performance)