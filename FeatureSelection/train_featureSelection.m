%% Feature selection
%% Motor imagery - BCI : Train

dataset = 'competIVdatasetIIa';
extrFeatAlg = 'FBCSP';
featSelAlg = 'MIBIF';

rootPath = '../../02Data/';

inputFiles = dir(sprintf('%s%s/trainFeatures/%s/none/*.mat', rootPath, dataset, extrFeatAlg));
Nsubjects = length(inputFiles);

for subject = 1:Nsubjects
    %% Load features
    nameFile = sprintf('%s%s/trainFeatures/%s/none/%s', rootPath, dataset, extrFeatAlg, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'features');
    fprintf('done\n');   
    
    % Print information features dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Num. Trials: %d\n', size(features.data,1));
    fprintf('- Num. Features: %i\n', size(features.data,3));
    fprintf('----------------------------------\n\n');
    
    %% Feature Selection    
    if exist([featSelAlg 'train'],'file') ~= 2
        addpath(genpath(featSelAlg));
    end
    
    % time elased
    tstart = tic;

    featSelAlg_ = str2func(featSelAlg);
    [features, model] = featSelAlg_(features);
    
    % time elapsed
    elapsedTime = toc(tstart);
    
    %% Save
    out_dir = sprintf('%s%s/trainFeatures/%s/%s', rootPath, dataset, extrFeatAlg, featSelAlg);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end   

    nameFile = sprintf('%s/%s', out_dir, inputFiles(subject,1).name);
    
    fprintf('Saving feature selection model ''%s'' ... ', nameFile);
    save(nameFile,'subject','features','model','elapsedTime')
    fprintf('done\n');
    
    fprintf('\n\n')
end