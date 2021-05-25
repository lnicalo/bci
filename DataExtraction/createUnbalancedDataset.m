%% Build 10-fold CV dataset
path = '../../02Data/';
dataset = 'competIVdatasetIIa1_2';
subjectName = 'subject';
percent_remove = 0:10:90;
Nsubjects = length(dir(sprintf('%s%s/eeg/%s*.mat', path, dataset, subjectName)));

for subject = 1:Nsubjects
    load( sprintf('%s%s/eeg/%s%i.mat', path, dataset, subjectName, subject));
    
    eeg_aux = eeg;
    nTrials_aux = nTrials;
    trueLabel_aux = trueLabel;
    validTrial_aux = validTrial;
    classes = unique(trueLabel_aux);
    
    for p = 1:length(percent_remove)
        Ntr = nTrials(1,1);
        
        % find index with class equals to first class
        ind1 = find(trueLabel_aux(2,:) == classes(1));
        
        % index to remove
        rm_trials = round( percent_remove(p)/100 * length(ind1) );
        rm_ind1 = ind1(end - rm_trials+1:end);
        
        % removing
        trueLabel_aux_p = trueLabel_aux(2,:);
        trueLabel_aux_p(rm_ind1) = [];
        eeg_aux_p = eeg_aux(2,:,:,:);
        eeg_aux_p(:,rm_ind1,:,:) = [];
        validTrial_aux_p = validTrial_aux(2,:);
        validTrial_aux_p(rm_ind1) = [];
        
        Nt = nTrials_aux - length(rm_ind1);
        nTrials = [Ntr; Nt];
        nTrials_max = max(Ntr, Nt);
        
        trueLabel = NaN(2, nTrials_max);
        trueLabel(1,1:Ntr) = trueLabel_aux(1,:);
        trueLabel(2,1:Nt)= trueLabel_aux_p;
        mean(trueLabel_aux_p == 2)
        
        validTrial = zeros(2 ,nTrials_max);
        validTrial(1, 1:Ntr) = validTrial_aux(1,:);
        validTrial(2, 1:Nt)= validTrial_aux_p;
        
        eeg = NaN(2, nTrials_max, size(eeg,3), size(eeg,4));
        eeg(1, 1:Ntr,:,:) = eeg_aux(1,:,:,:);
        eeg(2, 1:Nt,:,:)= eeg_aux_p;
        
        % Create dir if it does not exist
        out_dir = sprintf('%s%sTestRm/eeg', path, dataset);
        if exist(out_dir, 'dir') ~= 7
            mkdir(out_dir);
        end
        
        file = sprintf('%s/subject%02iRm%03i.mat', out_dir, subject, 100 - percent_remove(p));
        fprintf('Guardando %s ...\n', file)
        save(file, 'nTrials', 'trueLabel', 'validTrial', 'eeg', 'fs');
    end    
end