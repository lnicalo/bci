% SpecCSPtest
function extractedFeatures = CS_SpecCSPtrain(EEGdata, models)
% SpecCSPtest
% 
% Default:
%

options = models.options;

% Display options
switch options.display
    case 1
        fprintf('%s -------- \n', models.ID)
    case 2
        fprintf('%s -------- \n', models.ID)
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
Nsamples = size(EEGdata.eeg, 2);
fs = fs / Ndec;
window = floor ( options.window / Ndec );
overlap = floor ( options.overlap / Ndec );

%% Flat spatial filters
Nmodels = length(models.model);
spatialFilter = [];
for i = 1:Nmodels
    aux_filters = models.model{i,1}.spatialFilter;
    spatialFilter = cat(2, spatialFilter, aux_filters);
end
%% Spatial filtering
width = ceil( options.width / fs * nfft );
freq_overlap = ceil ( options.freq_overlap / fs * nfft );
ind = 1:(width - freq_overlap):(nfft/2 - width);
Nwidth = length( ind );

if Nwidth == 0
    Nwidth = 1;
    ind = 1;
    width = nfft/2;
end

Nclasses = length(unique(EEGdata.trueLabel(~isnan(EEGdata.trueLabel))));
m = options.spatialFilter.m;
NspatialFilters = Nclasses * 2 * m * Nmodels;
Nfeatures = NspatialFilters * Nwidth;
Nsegments = length(window : (window - overlap) : Nsamples); 

extractedFeatures = NaN(Ntrials, Nsegments, Nfeatures);

reverseStr = '';
for l = 1:Nsegments    
    % EEG data - window 
    s = squeeze(EEGdata.eeg(:, 1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:));
    
    % FFT
    s_fft = fft(s, nfft, 2);
    
    % Coherence
    scms = specSCM(s_fft(:,1:nfft/2,:));
    
    % Promediado en el espectro
    scms_mean = NaN(Ntrials, Nchannels, Nchannels, Nwidth);
    for i = 1:Nwidth
        scms_mean(:,:,:,i) = mean(scms(:,:,:,ind(i):ind(i)+width),4);
    end
    clear scms
    
    % Load spatial filters at segment l
    W = spatialFilter(:,:,:,l);
        
    % Spatial filtering and features extraction
    spatialFilteredEEG = NaN(Ntrials, Nfeatures);
    for i = 1:Ntrials
        for j = 1:Nwidth
            aux = real( W(:,:,j)' * ( squeeze(scms_mean(i,:,:,j)) ) * W(:,:,j) );
            spatialFilteredEEG(i,(NspatialFilters * (j-1)+1) : NspatialFilters * j) ...
                = log(diag(aux) / trace(aux));
        end
    end
    
    % Save feature vector
    extractedFeatures(:,l,:) = spatialFilteredEEG;
    
    % Display progress
    if options.display > 0
        percentDone = 100 * l / Nsegments;
        msg = sprintf('SpecCSP: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end % Nsegments    

if options.display > 0
    fprintf('\n')
end


end
