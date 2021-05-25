%% Motor imagery - BCI
%% Feature extraction : Train
clear
dataset = 'competIVdatasetIIa1_2';
algorithm = 'SpecCSP';
featExtrAlg = ['CS_' algorithm]; 
variation = '';
rootPath = '../../02Data/';
session = 1;

inputFiles = dir(sprintf('%s%s/eeg/*.mat', rootPath, dataset));
Nsubjects = length(inputFiles);

%% Load trained models
models.model = cell(Nsubjects, 1);
for subject = 1:Nsubjects
    nameFile = sprintf('%s%s/trainFeatures/%s/none/%s', rootPath, dataset, algorithm, inputFiles(subject,1).name);
    load(nameFile,'model');
    models.model{subject, 1} = model;
end
models.ID = model.ID;
models.options = model.options;
%% EEG data processing
for subject = 1:Nsubjects
    %% Load EEG
    nameFile = sprintf('%s%s/eeg/%s', rootPath, dataset, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    EEGdata = load(nameFile);
    fprintf('done\n');
    
    % Print information dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Sampling frequency: %d Hz\n', EEGdata.fs);
    fprintf('- Num. Sessions: %d\n', size(EEGdata.eeg, 1));
    fprintf('- Num. Trials: %d\n', size(EEGdata.eeg, 2));
    fprintf('- Num. EEG channels: %i\n', size(EEGdata.eeg, 4));
    fprintf('- Trial length: %.02f s.\n', size(EEGdata.eeg, 3) / EEGdata.fs);
    fprintf('----------------------------------\n\n');
    
    % Select session
    fprintf('Training session: %d\n',session);
    EEGdata.nTrials = EEGdata.nTrials(session,:);
    EEGdata.eeg = squeeze(EEGdata.eeg(session,:,:,:));
    EEGdata.trueLabel = EEGdata.trueLabel(session,:);
    EEGdata.validTrial = EEGdata.validTrial(session,:);
    
    %% Feature Extraction
    features = [];
    
    if exist(featExtrAlg,'file') ~= 2
        addpath(genpath(featExtrAlg));
    end
    
    algorithm_ = str2func(featExtrAlg);    
    features.data = algorithm_(EEGdata, models);
    features.trueLabel = EEGdata.trueLabel;
    features.validTrial = EEGdata.validTrial;
    
    %% Save features and model   
    out_dir = sprintf('%s%s/trainFeatures/%s/none', rootPath, dataset, featExtrAlg, variation);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    nameFile = sprintf('%s/%s%s', out_dir, inputFiles(subject,1).name);
    
    fprintf('Saving features and model ''%s'' ... ', nameFile);
    save(nameFile,'subject','features','model','-v7.3')
    fprintf('done\n');
    
    fprintf('\n\n')
end