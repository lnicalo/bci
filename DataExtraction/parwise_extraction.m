path = '../../02Data/';
dataset = 'Essex2012';

inputFiles = dir(sprintf('%s%s/eeg/*.mat', path, dataset));
Nsubjects = length(inputFiles);

for subject = 1:Nsubjects
    %% Load EEG
    nameFile = sprintf('%s%s/eeg/%s', path, dataset, inputFiles(subject,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile);
    fprintf('done\n');
    
    classes = unique(trueLabel(~isnan(trueLabel)));
    classes = sort(classes,'descend');
    Nclasses = length(classes);
    
    validTrial_ = validTrial;
    trueLabel_  = trueLabel;
    eeg_        = eeg;
    clear validTrial trueLabel eeg;
    
    Nsesiones = size(validTrial_,1);   
    Ncanales  = size(eeg_,4);
    Nsamples  = size(eeg_,3);
    
    
    for class1 = 1:Nclasses
        for class2 = (class1+1):Nclasses
            nTrials = sum(trueLabel_ == class1 | trueLabel_ == class2,2)';
            nTrials_max = max( nTrials );
            
            validTrial = NaN(Nsesiones,nTrials_max);
            trueLabel  = NaN(Nsesiones,nTrials_max);
            eeg        = NaN(Nsesiones,nTrials_max,Nsamples,Ncanales);
            for k = 1:Nsesiones
                validTrial(k,1:nTrials(1,k)) = validTrial_(k,trueLabel_(k,:) == class1 | trueLabel_(k,:) == class2);
                eeg(k,1:nTrials(1,k),:,:)    = eeg_(k,trueLabel_(k,:) == class1 | trueLabel_(k,:) == class2,:,:);
                trueLabel(k,1:nTrials(1,k))  = trueLabel_(k,trueLabel_(k,:) == class1 | trueLabel_(k,:) == class2);                            
            end
            
            % Rename classes
            trueLabel = 1*(trueLabel == class1) + 2*(trueLabel == class2);
            
            % Save data
            % Create dir if it does not exist
            out_dir = sprintf('%s%s_%i_%i/eeg', path, dataset, class1, class2);
            if exist(out_dir, 'dir') ~= 7
                mkdir(out_dir);
            end

            file = sprintf('%s/%s', out_dir, inputFiles(subject,1).name);
            fprintf('Guardando %s ... ', file);    
            save(file, 'nTrials', 'trueLabel', 'validTrial', 'eeg', 'fs');
            fprintf('done\n');
        end
    end
end

