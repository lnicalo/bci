% FBCSP
function extractedFeatures = Cohtest(EEGdata, model)
% FBCSP
% 
% Default:
%

options = model.options;

% Display options
switch options.display
    case 1
        fprintf('%s -------- \n', model.ID)
    case 2
        fprintf('%s -------- \n', model.ID)
end


%% Decimate fs > options.th
Ntrials = EEGdata.nTrials;
Nchannels = size(EEGdata.eeg, 3);
Nsamples = size(EEGdata.eeg, 2);

nfft = options.nfft;
fs = EEGdata.fs;

Ndec = floor(fs / ( 2 * options.th) );

aux_eeg = NaN(Ntrials, floor(Nsamples/Ndec), Nchannels);
reverseStr = '';
for i = 1:Ntrials
    for c = 1:Nchannels
        aux_eeg(i,:,c) = decimate(squeeze( EEGdata.eeg(i,:,c) ), Ndec, 82, 'fir');
    end
    
    % Display progress
    if options.display > 0
        percentDone = 100 * i / Ntrials;
        msg = sprintf('Decimate: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end

EEGdata.eeg = aux_eeg;
clear aux_eeg;

% Update info and options because of decimate
Nsamples = size(EEGdata.eeg, 2);
fs = fs / Ndec;
window = floor ( options.window / Ndec );
overlap = floor ( options.overlap / Ndec );

%% Computing coherence
Nsegments = length(window : (window - overlap) : Nsamples); 

width = ceil( options.width / fs * nfft );
freq_overlap = ceil ( options.freq_overlap / fs * nfft );
ind = 1:(width - freq_overlap):(nfft/2 - width);
Nwidth = length( ind );

if Nwidth == 0
    Nwidth = 1;
    ind = 1;
    width = nfft/2;
end

Nfeatures = 0.5 * (Nchannels + 1) * Nchannels * Nwidth;    
extractedFeatures = NaN(Ntrials, Nsegments, Nfeatures);
ind_triu = itriu([Nchannels, Nchannels]);
ind_diag = idiag([Nchannels, Nchannels]);
reverseStr = '';
for l = 1:Nsegments    
    % EEG data - window 
    s = squeeze(EEGdata.eeg(:, 1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:));
    
    % FFT
    s_fft = fft(s, nfft, 2);
    
    % Coherence
    scms = abs( specSCM(s_fft(:,1:nfft/2,:)) );
    
    % Promediado en el espectro
    scms_mean = NaN(Ntrials, Nchannels, Nchannels, Nwidth);
    for i = 1:Nwidth
        scms_mean(:,:,:,i) = mean(scms(:,:,:,ind(i):ind(i)+width),4);
    end
    clear scms
    
    % Normalization
    
    % Store extracted features
    scms_mean = permute(scms_mean,[1 4 2 3]);
    scms_mean = scms_mean(:,:,ind_triu);
    extractedFeatures(:,l,:) = scms_mean(:,:);
    
    % Display progress
    if options.display > 0
        percentDone = 100 * l / Nsegments;
        msg = sprintf('Coherence: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    
    
end % Nsegments    

if options.display > 0
    fprintf('\n')
end


end