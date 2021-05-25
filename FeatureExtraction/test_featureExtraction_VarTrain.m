%% Motor imagery - BCI : Test
clear

dataset = 'competIVdatasetIIa1_2';
extractionFolder = 'FBCSP';
rootPath = '../../02Data/';
session = 2;
trainRatio = 25;
inputFiles = dir(sprintf('%s%s/eeg/*.mat', rootPath, dataset));
Nsubjects = length(inputFiles);

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
    fprintf('Test session %d\n',session);
    EEGdata.nTrials = EEGdata.nTrials(1,:);
    EEGdata.eeg = squeeze(EEGdata.eeg(session,:,:,:));
    EEGdata.trueLabel = EEGdata.trueLabel(session,:);
    EEGdata.validTrial = EEGdata.validTrial(session,:);
    
    %% Load trained model
    nameFile = sprintf('%s%s/trainFeaturesVT/%sTR%02i/none/%s', rootPath, dataset, extractionFolder, ...
        trainRatio, inputFiles(subject,1).name);
    load(nameFile,'model');
    
    %% Feature Extraction
    features = [];  
    algorithm = model.ID;
    if exist(algorithm,'file') ~= 2
        addpath(genpath(algorithm));
    end
    
    algorithm_ = str2func(algorithm);
    [features.data, model] = algorithm_(EEGdata, model);
    features.trueLabel = EEGdata.trueLabel;
    features.validTrial = EEGdata.validTrial;
    
    %% Save    
    out_dir = sprintf('%s%s/testFeaturesVT/%sTR%02i/none', rootPath, dataset, extractionFolder, trainRatio);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    nameFile = sprintf('%s/%s', out_dir, inputFiles(subject,1).name);
    
    fprintf('Saving features and model ''%s'' ... ', nameFile);
    save(nameFile,'subject','features')
    fprintf('done\n');
    
    fprintf('\n\n')
end