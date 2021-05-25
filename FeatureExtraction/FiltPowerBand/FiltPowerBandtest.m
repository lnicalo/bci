% FBCSP
function extractedFeatures = FiltPowerBandtest(EEGdata, model)
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
        fprintf(' Temporal filters:\n');
        fprintf('    [%0.2f %0.2f] ', options.tempFilter.freqBands);
        fprintf('\n');
        fprintf('    Delta: %0.2f \n', options.tempFilter.delta);
        fprintf('    Attenuation: %0.2f dB \n', 20 * log( options.tempFilter.attenuation) )
        fprintf('    Band pass Ripple: %0.2f dB \n', 20 * log( options.tempFilter.ripple ) )
end


%% Filtering EEG
Ntrials = EEGdata.nTrials;
NtempFilters = size(options.tempFilter.freqBands, 1);
Nsamples = size(EEGdata.eeg, 2);
Nchannels = size(EEGdata.eeg, 3);

eeg_band = NaN(Ntrials, Nsamples, Nchannels, NtempFilters);
reverseStr = '';
for k = 1:NtempFilters % Filters
    eeg_band(:,:,:,k) = filter(model.tempFilter{1,k}, 1, EEGdata.eeg, [], 2);
    
    if options.display > 0
        percentDone = 100 * k / NtempFilters;
        msg = sprintf('Temporal filtering: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end

%% Power band
window = options.window;
overlap = options.overlap;

% Power 2
eeg_band = eeg_band.^2;

% Low pass
h = ones(1, window);

reverseStr = '';
for i = 1:NtempFilters
    eeg_band(:,:,:,i) = filter(h, 1, eeg_band(:,:,:,i), [], 2);
    
    if options.display > 0
        percentDone = 100 * i / NtempFilters;
        msg = sprintf('Computing power: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end

% Remove
eeg_band = eeg_band(:, window+1:end,:,:);
% Subsampling
eeg_band = eeg_band(:,1:(window - overlap):end,:,:);

% Normalization
% eeg_band = eeg_band./repmat(sum(eeg_band, 4),[1 1 1 NtempFilters]);


% extractedFeatures
extractedFeatures = eeg_band(:,:,:);
end
