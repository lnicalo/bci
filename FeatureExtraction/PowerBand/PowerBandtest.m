% FBCSP
function extractedFeatures = PowerBandtest(EEGdata, model)
% FBCSP
% 
% Default:
%

options = model.options;

% Display options
switch options.display
    case 1
        fprintf('Power band -------- \n')
    case 2
        fprintf('Power band -------- \n')
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

%% Computing band power
Nsegments = length(window : (window - overlap) : Nsamples); 

width = ceil( options.width / fs * nfft );
freq_overlap = ceil ( options.freq_overlap / fs * nfft );
Nwidth = length(width:(width - freq_overlap):nfft/2);

if Nwidth == 0
    Nwidth = 1;
    width = nfft/2;
end


Nfeatures = Nwidth * Nchannels;    
extractedFeatures = NaN(Ntrials, Nsegments, Nfeatures);
reverseStr = '';
for l = 1:Nsegments    
    % EEG data - window 
    s = squeeze(EEGdata.eeg(:, 1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:));
    
    % FFT
    s_fft = fft(s, nfft, 2);
    s_fft = abs( s_fft(:,1:nfft/2+1,:) );
    
    % spectral average
    h = ones(1, width);
    y = filter(h, 1, s_fft,[],2);
    y = y(:, width:(width - freq_overlap):end, :);
    
    % normalization
    y = y ./ repmat(sum(y,3),[1 1 Nchannels]);

    % Store extracted features
    extractedFeatures(:,l,:) = y(:,:);

    % Display progress
    if options.display > 0
        percentDone = 100 * l / Nsegments;
        msg = sprintf('Computing power bands: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    
    
end % Nsegments    

if options.display > 0
    fprintf('\n')
end

end
