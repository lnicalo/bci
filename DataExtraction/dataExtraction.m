%% Data extraction
clear
datasetName = 'GIBdataset2014';
rootPath = '../../02Data/';
sessions = [1 2];
Nsessions = length( sessions );
dataset = cell(Nsessions, 1);

folder = sprintf('%s%s/BCI2000files/*', rootPath, datasetName);
subjectFolder = dir(folder);
subjectFolder = subjectFolder(arrayfun(@(x) x.name(1), subjectFolder) ~= '.'); % remove . and .. directories

Nsubjects = length(subjectFolder);

for subject = 1 : Nsubjects
    for s_ind = 1 : Nsessions
        %% List file for session
        folder = sprintf('%s%s/BCI2000files/%s/*%03i*.dat', rootPath, ...
            datasetName, subjectFolder(subject, 1).name, sessions(s_ind));
        inputFiles = dir(folder);
        Nfiles = length(inputFiles);
        
        %% Read data
        session = [];
        session.eeg = [];
        session.fs  = 0;
        session.nTrials = 0;
        session.trueLabel = [];
        session.validTrial = [];
        
        for i = 1:Nfiles
            nameFile = sprintf('%s%s/BCI2000files/%s/%s', rootPath, datasetName, ...
                subjectFolder(subject, 1).name, inputFiles(i,1).name);
            fprintf('Loading ''%s'' ... ', nameFile);
            [ signal, states, parameters, total_samples ] = load_bcidat(nameFile);
            fprintf('done\n');
            
            
            %% fs
            fs = parameters.SamplingRate.NumericValue;
            
            %% Labels
            labels = double(states.StimulusCode);
            labels = labels([1;diff(labels)]~=0);
            if labels(1) ~= 0
                labels = labels(2:end);
            end
            labels = labels(labels ~= 0)';
            trueLabel = labels;
            
            
            %% Signal
            signal = double(signal);
            
            % Margen 1 segundo a cada lado
            M1 = 1;
            M2 = 1;
            
            % Eliminamos el pre-run
            labels = double(states.StimulusCode);
            preRun =  parameters.PreRunDuration.NumericValue - M1;
            signal = signal(preRun*fs+1:end,1:15);
            labels = labels(preRun*fs+1:end,:);
            
            ind = find(diff(labels) > 0);
            % Tiempo entre pruebas
            ISI = parameters.ISIMinDuration.NumericValue;
            
            % Tiempo duracion del estimulo
            Estimulus = parameters.StimulusDuration.NumericValue;
            
            
            
            % Tiempo prueba
            S = (ISI + Estimulus + M1 + M2)*fs;
            
            nTrials = length(ind);
            C = size(signal,2);
            eeg_session = zeros(nTrials,S,C);
            for j = 1:length(ind)
                ind0 = ind(j)-M1*fs+1;
                ind_end = ind0 + S - 1;
                
                sel = ind0:min(ind_end,length(signal));
                eeg_session(j,1:length(sel),:) = signal(sel,:);
            end
            
            %% ValidTrials
            % Todas validas
            validTrial = ones(1,nTrials);
            
            %% Save
            % Structura
            session.eeg = cat(1, session.eeg, eeg_session );
            session.fs  = fs;
            session.nTrials = session.nTrials + nTrials;
            session.trueLabel = cat(2, session.trueLabel, trueLabel);
            session.validTrial = cat(2, session.validTrial, validTrial);
        end
        dataset{s_ind,1} = session;
    end
    clear session signal
    
    %% Store session
    %
    
    % Compute max. trials
    nTrials = 0;
    for s_ind = 1 : Nsessions
        if dataset{s_ind, 1}.nTrials > nTrials
            nTrials = dataset{s_ind, 1}.nTrials;
        end
    end
    
    % Build subject data
    S = size(dataset{1,1}.eeg, 2);
    C = size(dataset{1,1}.eeg, 3);
    eeg = NaN(Nsessions, nTrials, S, C);
    validTrial = zeros(Nsessions, nTrials);
    trueLabel  = NaN(Nsessions, nTrials);
    
    for i = 1:Nsessions
        eeg(i, 1:dataset{i,1}.nTrials,:,:) = dataset{i,1}.eeg;
        validTrial(i, 1:dataset{i,1}.nTrials) = dataset{i,1}.validTrial;
        trueLabel(i, 1:dataset{i,1}.nTrials)  = dataset{i,1}.trueLabel;
    end
    
    % Save subject data
    out_dir = sprintf('%s%s/eeg', rootPath, datasetName);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    namefile = sprintf('%s/%s.mat', out_dir, subjectFolder(subject, 1).name);
    
    fprintf('Saving EEG data ''%s'' ... ', namefile);
    save(namefile,'eeg','validTrial','trueLabel','fs','nTrials')
    fprintf('done\n');
end
    