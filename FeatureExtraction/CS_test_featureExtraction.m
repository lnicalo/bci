%% Motor imagery - BCI : Test
clear

dataset = 'Essex2012_1_2';
extractionFolder = 'CSFBCSPU';
optionsFile = 'static';
rootPath = '../../02Data/';
session = 2;

inputFiles = dir(sprintf('%s%s/eeg/*.mat', rootPath, dataset));
Nsubjects = length(inputFiles);

for subject = 1:Nsubjects
    %% Load EEG
    nameFile = sprintf('%s%s/eeg/%s', rootPath, dataset, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    EEGdata = load(nameFile);
    fprintf('done\n');
    
    % Select session
    fprintf('Test session %d\n',session);
    EEGdata.nTrials = EEGdata.nTrials(1,:);
    EEGdata.eeg = squeeze(EEGdata.eeg(session,:,:,:));
    EEGdata.trueLabel = EEGdata.trueLabel(session,:);
    EEGdata.validTrial = EEGdata.validTrial(session,:);
    
    % Select trials    
    EEGdata.eeg = EEGdata.eeg(~isnan(EEGdata.trueLabel),:,:);
    EEGdata.trueLabel = EEGdata.trueLabel(:,~isnan(EEGdata.trueLabel));
    EEGdata.validTrial = EEGdata.validTrial(:,~isnan(EEGdata.trueLabel));
    EEGdata.nTrials = length(EEGdata.trueLabel);
    
    % Print information dataset
    fprintf('----- Dataset %s ------\n', dataset);
    fprintf('- Sampling frequency: %d Hz\n', EEGdata.fs);
    fprintf('- Num. Trials: %d\n', size(EEGdata.eeg, 1));
    fprintf('- Num. EEG channels: %i\n', size(EEGdata.eeg, 3));
    fprintf('- Trial length: %.02f s.\n', size(EEGdata.eeg, 2) / EEGdata.fs);
    fprintf('----------------------------------\n\n');
    
    %% Load trained model
    nameFile = sprintf('%s%s/trainFeatures/%s%s/none/%s', rootPath, dataset, extractionFolder, optionsFile, inputFiles(subject,1).name);
    load(nameFile,'model');
    
    %% Feature Extraction
    algorithm = model.ID;
    if exist(algorithm,'file') ~= 2
        addpath(genpath(algorithm));
    end
    
    algorithm_ = str2func(algorithm);
    [features, model] = algorithm_(EEGdata, [], model);
    
    %% Save    
    out_dir = sprintf('%s%s/testFeatures/%s%s/none', rootPath, dataset, extractionFolder, optionsFile);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    nameFile = sprintf('%s/%s', out_dir, inputFiles(subject,1).name);
    
    fprintf('Saving test features ''%s'' ... ', nameFile);
    save(nameFile,'subject','features')
    fprintf('done\n');
    
    fprintf('\n\n')
end