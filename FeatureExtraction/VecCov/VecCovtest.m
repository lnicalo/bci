% FBCSP
function extractedFeatures = VecCovtest(EEGdata, model)
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
for i = 1:Ntrials % Trials
    for j = 1:Nchannels % Channels
        for k = 1:NtempFilters % Filters
            eeg_band(i,:,j,k) = conv(squeeze(EEGdata.eeg(i,:,j)), model.tempFilter{1,k},'same');
        end
    end
    
    if options.display > 0
        percentDone = 100 * i / Ntrials;
        msg = sprintf('Temporal filtering: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end

%% Matrix covariance
window = options.window;
overlap = options.overlap;
Nsegments = length(window:(window-overlap):Nsamples); 
Nfeatures = NtempFilters * ( Nchannels ^ 2 + Nchannels ) * 0.5;
extractedFeatures = NaN(Ntrials, Nsegments, Nfeatures);
reverseStr = '';

for l = 1:Nsegments    
    feats = [];
    for j = 1:NtempFilters        
        % s = window x Nchannels
        s = squeeze(eeg_band(:,1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:,j));
        
        % Computing Spatial Covariances Matrices
        scms = SCM(s);
        aux = triu(ones(Nchannels));
        aux = aux(:);
        feats = cat(2, feats, scms(:,aux == 1));        
    end % NtempFilters
    
    % Save feature vector
    extractedFeatures(:, l, :) = feats;
    
    % Display progress
    if options.display > 0
        percentDone = 100 * l / Nsegments;
        msg = sprintf('Computing covariances: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end % Nsegments    

if options.display > 0
    fprintf('\n')
end
end
