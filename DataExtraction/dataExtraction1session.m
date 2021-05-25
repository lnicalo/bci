%% Data extraction
clear
datasetName = 'GIBdataset2014Victor';
rootPath = '../../02Data/';
session = 1;

folder = sprintf('%s%s/BCI2000files/*%03i*.dat', rootPath, datasetName, session);
inputFiles = dir(folder);
Nfiles = length(inputFiles);

%% Read data
dataset = cell(Nfiles,1);
for i = 1:Nfiles
    nameFile = sprintf('%s%s/BCI2000files/%s', rootPath, datasetName, inputFiles(i,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    [ signal, states, parameters, total_samples ] = load_bcidat(nameFile);
    fprintf('done\n');

    
    %% fs
    fs = parameters.SamplingRate.NumericValue;
    
    %% Labels
    labels = double(states.StimulusCode);
    labels = labels([1;diff(labels)]~=0);
    plot(labels);
    if labels(1) ~= 0
        labels = labels(2:end);
    end
    labels = labels(labels ~= 0)';
    trueLabel = labels;
    
    
    %% Signal
    signal = double(signal);
    
    % Margen 1 segundo a cada lado
    M1 = 2;
    M2 = 5;
    
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
    ronda = [];
    ronda.eeg = eeg_session;
    ronda.fs  = fs;
    ronda.nTrials = nTrials;
    ronda.trueLabel = trueLabel;
    ronda.validTrial = validTrial;
    
    dataset{i,1} = ronda;
end
clear eeg_session signal ronda 

%% Store cross validation
%
nTrialsFile = nTrials;
nTrials = (Nfiles-1)*nTrials; % Numero de pruebas maxima por session
eeg = NaN(2,nTrials,S,C);
validTrial = zeros(2,nTrials);
trueLabel  = NaN(2,nTrials);

for i = 1:Nfiles  
    % Training session
    v = setdiff(1:Nfiles,i);
    
    ind = 1:nTrialsFile;
    for j = v       
        ronda = dataset{j,1};
        eeg(1,ind,:,:) = ronda.eeg;
        validTrial(1,ind) = ronda.validTrial;
        trueLabel(1,ind)  = ronda.trueLabel;      
        
        % Update index
        ind = ind + nTrialsFile;
    end
    
    % Test session
    ronda = dataset{i,1};
    eeg(2,1:nTrialsFile,:,:) = ronda.eeg;
    validTrial(2,1:nTrialsFile) = ronda.validTrial;
    trueLabel(2,1:nTrialsFile)  = ronda.trueLabel;
    
    % Save file
    out_dir = sprintf('%s%s/eeg', rootPath, datasetName);
    if exist(out_dir, 'dir') ~= 7
        mkdir(out_dir);
    end
    
    namefile = sprintf('%s/subject1CV%02i', out_dir, i);
    
    fprintf('Saving EEG data ''%s'' ... ', namefile);
    save(namefile,'eeg','validTrial','trueLabel','fs','nTrials')
    fprintf('done\n');  
end
