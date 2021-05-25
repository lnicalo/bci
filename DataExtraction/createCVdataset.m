%% Build 10-fold CV dataset
path = '../../02Data/';
dataset = 'competIVdatasetIIaTrainRm075';
folds = 10;

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
    
    s = RandStream('mt19937ar','Seed',1);
    RandStream.setGlobalStream(s);
    indices = crossvalind('Kfold', trueLabel_CV, folds);
    
    for i = 1:folds
        test = (indices == i); train = ~test;
        Nt = sum(test);
        Ntr = sum(train);
        nTrials = [Ntr; Nt];
        
        trueLabel = NaN(2, Ntr);
        trueLabel(1,1:Ntr) = trueLabel_CV(1, train);
        trueLabel(2,1:Nt)= trueLabel_CV(1, test);
        
        if length(unique(trueLabel(1,:)) ) ~= 4 && ...
                length(unique(trueLabel(2,~isnan(trueLabel(2,:))))) ~= 4
            error('No enough class labels');
        end
        
        validTrial = zeros(2,Ntr);
        validTrial(1, 1:Ntr) = validTrial_CV(1, train);
        validTrial(2, 1:Nt)= validTrial_CV(1, test);
        
        eeg = NaN(2, Ntr, size(eeg,3), size(eeg,4));
        eeg(1, 1:Ntr,:,:) = eeg_CV(1, train,:,:);
        eeg(2, 1:Nt,:,:)= eeg_CV(1, test,:,:);
        
        % Create dir if it does not exist
        out_dir = sprintf('%s%s%ifoldCV/eeg', path, dataset, folds);
        if exist(out_dir, 'dir') ~= 7
            mkdir(out_dir);
        end

        file = sprintf('%s/%sCV%02i.mat', out_dir, strrep(inputFiles(subject,1).name, '.mat', ''), i);
        fprintf('Guardando %s ...\n', file)
        save(file, 'nTrials', 'trueLabel', 'validTrial', 'eeg', 'fs');
    end
end