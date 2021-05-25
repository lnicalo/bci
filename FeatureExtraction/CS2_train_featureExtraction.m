%% Motor imagery - BCI
%% Feature extraction : Train
clear
dataset = 'competIVdatasetIIa1_2';
algorithm = 'CSFBCSPU';
optionsFile = 'ext';
rootPath = '../../02Data/';
Nsession = 2;

inputFiles = dir(sprintf('%s%s/eeg/*.mat', rootPath, dataset));
Nsubjects = length(inputFiles);

%% Load data
EEGdata = cell(Nsubjects, 1);
for subject = 1:Nsubjects
    for session = 1:Nsession
        %% Load EEG
        nameFile = sprintf('%s%s/eeg/%s', rootPath, dataset, inputFiles(subject,1).name);
        fprintf('Loading ''%s'' ... ', nameFile);
        EEGdata_u = load(nameFile);
        fprintf('done\n');
        
        % Print information dataset
        fprintf('----- Dataset %s ------\n', dataset);
        fprintf('- Sampling frequency: %d Hz\n', EEGdata_u.fs);
        fprintf('- Num. Sessions: %d\n', size(EEGdata_u.eeg, 1));
        fprintf('- Num. Trials: %d\n', size(EEGdata_u.eeg, 2));
        fprintf('- Num. EEG channels: %i\n', size(EEGdata_u.eeg, 4));
        fprintf('- Trial length: %.02f s.\n', size(EEGdata_u.eeg, 3) / EEGdata_u.fs);
        fprintf('----------------------------------\n\n');
        
        % Select session
        fprintf('Training session: %d\n',session);
        EEGdata_u.nTrials = EEGdata_u.nTrials; % (:,session);
        EEGdata_u.eeg = squeeze(EEGdata_u.eeg(session,:,:,:));
        EEGdata_u.trueLabel = EEGdata_u.trueLabel(session,:);
        EEGdata_u.validTrial = EEGdata_u.validTrial(session,:);
        
        % Select trials
        EEGdata_u.eeg = EEGdata_u.eeg(~isnan(EEGdata_u.trueLabel),:,:);
        EEGdata_u.trueLabel = EEGdata_u.trueLabel(:,~isnan(EEGdata_u.trueLabel));
        EEGdata_u.validTrial = EEGdata_u.validTrial(:,~isnan(EEGdata_u.trueLabel));
        EEGdata_u.nTrials = length(EEGdata_u.trueLabel);
        
        % Store data
        EEGdata{subject, session} = EEGdata_u;
    end
end


%% Feature Extraction
if exist(algorithm,'file') ~= 2
    addpath(genpath(algorithm));
end


for subject = 1:Nsubjects
    % time elased
    tstart = tic;
    fprintf('Processing subject %s ... \n',inputFiles(subject,1).name);
    algorithm_ = str2func(algorithm);
    
    EEGdataCS = EEGdata(setdiff(1:Nsubjects, subject), :);
    EEGdataCS = EEGdataCS(:);
    [features, model] = algorithm_(EEGdata{subject, 1}, EEGdataCS);
    
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

