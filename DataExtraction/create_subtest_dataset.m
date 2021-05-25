%% Build train- X test dataset
path = '../../02Data/';
dataset = 'competIVdatasetIIa';
subjectName = 'subject';
testTrials = 50;

Nsubjects = length(dir(sprintf('%s%s/eeg/%s*.mat', path, dataset, subjectName)));

for subject = 1:Nsubjects
    load( sprintf('%s%s/eeg/%s%i.mat', path, dataset, subjectName, subject));
    
    eeg_aux = eeg;
    trainTrials = nTrials;
    trueLabel_aux = trueLabel;
    validTrial_aux = validTrial;
    
    nTrials = [trainTrials; testTrials];
    nTrials_max = max(trainTrials, testTrials);
    trueLabel = NaN(2, nTrials_max);
    trueLabel(1,1:trainTrials) = trueLabel_aux(1, 1:trainTrials);
    trueLabel(2,1:testTrials)= trueLabel_aux(2, 1:testTrials);
    
    validTrial = zeros(2, nTrials_max);
    validTrial(1, 1:trainTrials) = validTrial_aux(1, 1:trainTrials);
    validTrial(2, 1:testTrials)= validTrial_aux(2, 1:testTrials);
    
    eeg = NaN(2, nTrials_max, size(eeg,3), size(eeg,4));
    eeg(1, 1:trainTrials,:,:) = eeg_aux(1, 1:trainTrials,:,:);
    eeg(2, 1:testTrials,:,:) = eeg_aux(2, 1:testTrials,:,:);
    
    out_dataset = sprintf('%s%itest', dataset, testTrials);
    out_dir = sprintf('%s%s/eeg', path, dataset_out);
    
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    file = sprintf('%s/%s%i.mat', out_dir, subjectName, subject);
    fprintf('Saving %s ...\n', file)
    save(file, 'nTrials', 'trueLabel', 'validTrial', 'eeg', 'fs');
end


