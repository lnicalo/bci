% CovMattest
function extractedFeatures = CovMattest(EEGdata, model)
% CovMattest
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

aux_eeg = randn(Ntrials, floor(Nsamples/Ndec), Nchannels);
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
fs = fs / Ndec;
window = floor( options.window / Ndec );
l = floor( options.position / Ndec );

%% Covariance matrix extraction
width = ceil( options.width / fs * nfft );
freq_overlap = ceil ( options.freq_overlap / fs * nfft );
ind = 1:(width - freq_overlap):(nfft/2 - width);
Nwidth = length( ind );

if Nwidth == 0
    Nwidth = 1;
    ind = 1;
    width = nfft/2;
end

% EEG data - window 
s = squeeze(EEGdata.eeg(:, l:l+window-1,:));

% FFT
s_fft = fft(s, nfft, 2);
s_fft = 2 * real( s_fft(:, 1:nfft/2, :) );

% Coherence
scms = specSCM(s_fft(:,1:nfft/2,:));

% Spectral average
scms_mean = NaN(Ntrials, Nchannels, Nchannels, Nwidth);
for i = 1:Nwidth
    scms_mean(:,:,:,i) = mean(scms(:,:,:,ind(i):ind(i)+width),4);
end
clear scms

% Save feature vector
% Ntrials x Nmatcov x Nchannels x Nchannels
extractedFeatures = NaN(Ntrials, 1, Nwidth, Nchannels, Nchannels);
extractedFeatures(:,1,:,:,:) = permute( scms_mean, [1 4 2 3]);

end
