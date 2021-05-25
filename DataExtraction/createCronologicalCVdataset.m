%% Build 10-fold CV dataset
path = '../../02Data/';
dataset = 'competIVdatasetIIaTrainRm075';
subjectName = 'subject';
percent_split = 60;

inputFiles = dir(sprintf('%s%s/eeg/*.mat', path, dataset));
Nsubjects = length(inputFiles);

for subject = 1:Nsubjects
    %% Load EEG
    nameFile = sprintf('%s%s/eeg/%s', path, dataset, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile);
    fprintf('done\n');
    
    eeg_CV = eeg(1,1:nTrials(1,1),:,:);
    nTrials_CV = nTrials(1,1);
    trueLabel_CV = trueLabel(1, 1:nTrials(1,1));
    validTrial_CV = validTrial(1, 1:nTrials(1,1));
    
    Ntr = round(nTrials_CV * percent_split / 100 );
    Nt = nTrials_CV - Ntr;
    nTrials = [Ntr; Nt];
    
    train = 1:Ntr;
    test  = (Ntr+1):nTrials_CV;
    
    trueLabel = NaN(2, Ntr);
    trueLabel(1,1:Ntr) = trueLabel_CV(1, train);
    trueLabel(2,1:Nt)= trueLabel_CV(1, test);
    
    validTrial = zeros(2,Ntr);
    validTrial(1, 1:Ntr) = validTrial_CV(1, train);
    validTrial(2, 1:Nt)= validTrial_CV(1, test);
    
    eeg = NaN(2, Ntr, size(eeg,3), size(eeg,4));
    eeg(1, 1:Ntr,:,:) = eeg_CV(1, train,:,:);
    eeg(2, 1:Nt,:,:)= eeg_CV(1, test,:,:);
    
    % Create dir if it does not exist
    out_dir = sprintf('%s%sCrCV%i/eeg', path, dataset, percent_split);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    file = sprintf('%s/%s', out_dir, inputFiles(subject,1).name);
    fprintf('Guardando %s ... ', file);    
    save(file, 'nTrials', 'trueLabel', 'validTrial', 'eeg', 'fs');
    fprintf('done');
end