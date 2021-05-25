%% Motor imagery - BCI
%% Feature extraction : Train
clear
dataset = 'competIVdatasetIIa';
algorithm = 'DSAFBCSP';
optionsFile = '';
rootPath = '../../02Data/';
session = 1;

inputFiles = dir(sprintf('%s%s/eeg/*.mat', rootPath, dataset));
Nsubjects = length(inputFiles);

for subject = 6:Nsubjects
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
    
    % Select trials    
    EEGdata.eeg = EEGdata.eeg(~isnan(EEGdata.trueLabel),:,:);
    EEGdata.trueLabel = EEGdata.trueLabel(:,~isnan(EEGdata.trueLabel));
    EEGdata.validTrial = EEGdata.validTrial(:,~isnan(EEGdata.trueLabel));
    EEGdata.nTrials = length(EEGdata.trueLabel);
    
    %% Feature Extraction
    if exist(algorithm,'file') ~= 2
        addpath(genpath(algorithm));
    end
    
    % time elased
    tstart = tic;
    
    algorithm_ = str2func(algorithm);
    [features, model] = algorithm_(EEGdata);
    
    % time elapsed
    elapsedTime = toc(tstart);
    
    %% Save features and model   
    out_dir = sprintf('%s%s/trainFeatures/%s%s/none', rootPath, dataset, algorithm, optionsFile);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    nameFile = sprintf('%s/%s%s', out_dir, inputFiles(subject,1).name);
    
    fprintf('Saving features and model ''%s'' ... ', nameFile);
    save(nameFile,'subject','features','model','elapsedTime', '-v7.3')
    fprintf('done\n');
    
    fprintf('\n\n')
end