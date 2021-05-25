% FBCSP
function extractedFeatures = AdaptFBCSPtest(EEGdata, model)
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
        
        fprintf(' Spatial filters:\n')
        fprintf('    Num. filters: %d\n', options.spatialFilter.m );
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

%% Spatial filtering
window = options.window;
overlap = options.overlap;
Nsegments = length(window:(window-overlap):Nsamples); 

Nclasses = length(unique(EEGdata.trueLabel(~isnan(EEGdata.trueLabel))));
m = options.spatialFilter.m;
NspatialFilters = Nclasses * 2 * m;
Nfeatures = NtempFilters * NspatialFilters;

extractedFeatures = NaN(Nfeatures, Nsegments, Ntrials);
reverseStr = '';

for l = 80    
    featureMatrix = NaN(Nfeatures, Ntrials);
    for j = 1:NtempFilters        
        % s = window x Nchannels
        s = squeeze(eeg_band(:,1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:,j));
        
        % Computing Spatial Covariances Matrices
        scms = SCM(s);        
        
        % Save spatial filters at temporal filter j and segment l
        W = model.spatialFilter(:,:,j,l);
        
        % Spatial filtering and features extraction
        spatialFilteredEEG = [];
        for i = 1:Ntrials
            aux = W' * ( squeeze(scms(i,:,:)) ) * W;
            extr_feat_class = log(diag(aux) / trace(aux));
            spatialFilteredEEG = cat(2, spatialFilteredEEG, extr_feat_class);
        end        
        
        K = spatialFilteredEEG' * spatialFilteredEEG;
        [U, V] = eigs(K,3);
        Pa = K * U;
        figure(1)
        scatter3(Pa(:,1), Pa(:,2),Pa(:,3),10,EEGdata.trueLabel)
        % CSP adapt
        ll = -loss( spatialFilteredEEG);
        if ll > 0
            W = normc(W);
            W  = CSP_adapt(scms, W);
            spatialFilteredEEG = featuresCSP(scms,W)';
        end
                
        K = spatialFilteredEEG' * spatialFilteredEEG;
        [U, V] = eigs(K,3);
        Pd = K * U;
        figure(2)
        scatter3(Pd(:,1), Pd(:,2),Pd(:,3),10,EEGdata.trueLabel)
        
        % Save feature vectors
        featureMatrix( (NspatialFilters*j - (NspatialFilters-1)) : NspatialFilters*j, :) = spatialFilteredEEG;
    end % NtempFilters
    
    extractedFeatures(:, l, :) = featureMatrix;
    
    % Display progress
    if options.display > 0
        percentDone = 100 * l / Nsegments;
        msg = sprintf('Spatial filtering: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
end % Nsegments    

if options.display > 0
    fprintf('\n')
end

extractedFeatures = permute(extractedFeatures,[3 2 1]);
end
