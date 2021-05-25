% FBCSP
function [extractedFeatures, model] = FiltPowerBandtrain(EEGdata, options)
% FBCSP
% 
% Default:
%
if ~exist('options', 'var')
    options = [];
end
if ~isfield(options,'window')
    % 2 seconds window
    options.window = 2*EEGdata.fs;
end

if ~isfield(options, 'overlap')
    % 98% overlap
    options.overlap = 0.98 * options.window;
end

% Temporal filtering options
if ~isfield(options, 'tempFilter')
    options.tempFilter = [];
end

if ~isfield(options.tempFilter, 'freqBands')
    % 4 - 8, 8 - 12, ..., 36 - 40 Hz
    options.tempFilter.freqBands = [4 8;8 12;12 16;16 20;20 24;24 28;28 32;32 36;36 40];
end

if ~isfield(options.tempFilter, 'delta')
    % Transition bandwidth
    options.tempFilter.delta = 2;
end

if ~isfield(options.tempFilter, 'attenuation')
    % Stop band attenuation
    options.tempFilter.attenuation = 0.0001;
end

if ~isfield(options.tempFilter, 'ripple')
    % Pass band ripple
    options.tempFilter.ripple = 10^(0.1/20) - 1;
end

options.tempFilter.fs = EEGdata.fs;

% Display options
% Default Moderate display level 1
if ~isfield(options, 'display');
    options.display = 1;
end


model = [];
model.ID = 'FiltPowerBand';
model.options = options;

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

%% Temporal filter design
model.tempFilter = tempFilterDesign(options.tempFilter);

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
