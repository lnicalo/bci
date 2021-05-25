%% Create Reduced Training Dataset
path = '../../02Data/';
dataset = 'competIVdatasetIIa1_2';
subjectName = 'subject';
percent_remove = 50;
Nsubjects = length(dir(sprintf('%s%s/eeg/%s*.mat', path, dataset, subjectName)));

for subject = 1:Nsubjects
    load( sprintf('%s%s/eeg/%s%i.mat', path, dataset, subjectName, subject));
    
    eeg_aux = eeg;
    nTrials_aux = nTrials;
    trueLabel_aux = trueLabel;
    validTrial_aux = validTrial;
    classes = unique(trueLabel_aux);
    
    for p = 1:length(percent_remove)
        Ntr = nTrials_aux(1,1);
        Nt = nTrials_aux(1,1);
        
        % number of trials to remove
        rm_trials = round( percent_remove(p)/100 * Ntr );
                
        % removing
        trueLabel_aux_p = trueLabel_aux(1,:);
        trueLabel_aux_p(end - rm_trials + 1:end) = [];
        eeg_aux_p = eeg_aux(1,:,:,:);
        eeg_aux_p(:,end - rm_trials + 1:end,:,:) = [];
        validTrial_aux_p = validTrial_aux(1,:);
        validTrial_aux_p(end - rm_trials + 1:end) = [];
        
        Ntr = nTrials_aux - rm_trials;
        nTrials = [Ntr; Nt];
        nTrials_max = max(Ntr, Nt);
        
        trueLabel = NaN(2, nTrials_max);
        trueLabel(1,1:Ntr) = trueLabel_aux_p;
        trueLabel(2,1:Nt)= trueLabel_aux(2,:);
        
        validTrial = zeros(2 ,nTrials_max);
        validTrial(1, 1:Ntr) = validTrial_aux_p;
        validTrial(2, 1:Nt)= validTrial_aux(2,:);
        
        eeg = NaN(2, nTrials_max, size(eeg,3), size(eeg,4));
        eeg(1, 1:Ntr,:,:) = eeg_aux_p;
        eeg(2, 1:Nt,:,:)= eeg_aux(2,:,:,:);
        
        % Create dir if it does not exist
        out_dir = sprintf('%s%sTrainRm%03i/eeg', path, dataset, 100 - percent_remove(p));
        if exist(out_dir, 'dir') ~= 7
            mkdir(out_dir);
        end
        
        file = sprintf('%s/subject%02i.mat', out_dir, subject);
        fprintf('Guardando %s ...\n', file)
        save(file, 'nTrials', 'trueLabel', 'validTrial', 'eeg', 'fs');
    end    
end