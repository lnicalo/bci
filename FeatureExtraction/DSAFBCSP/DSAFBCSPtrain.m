% DSAFBCSP
function [features, model] = DSAFBCSPtrain(EEGdata, options)
% DSAFBCSP
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
    options.overlap = 2*EEGdata.fs - 10;
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
    options.tempFilter.delta = 1;
end

if ~isfield(options.tempFilter, 'attenuation')
    % Stop band attenuation
    options.tempFilter.attenuation = 0.0001;
end

if ~isfield(options.tempFilter, 'ripple')
    % Pass band ripple
    options.tempFilter.ripple = 10^(0.2/20) - 1;
end

options.tempFilter.fs = EEGdata.fs;

% Spatial filtering options
if ~isfield(options, 'spatialFilter')
    options.spatialFilter = [];
end

% Number of spatial filters: 2*m
if ~isfield(options.spatialFilter, 'm')
    options.spatialFilter.m = 2;
end

% Number of spatial filters: 2*m
if ~isfield(options, 'artifactSelection')
    options.artifactSelection = true;
end

% Display options
% Default Moderate display level 1
if ~isfield(options, 'display');
    options.display = 1;
end


model = [];
model.ID = 'DSAFBCSP';
model.options = options;

% Display options
switch options.display
    case 1
        fprintf('DSAFBCSP -------- \n')
    case 2
        fprintf('DSAFBCSP -------- \n')
        fprintf(' Temporal filters:\n');
        fprintf('    [%0.2f %0.2f] ', options.tempFilter.freqBands);
        fprintf('\n');
        fprintf('    Delta: %0.2f \n', options.tempFilter.delta);
        fprintf('    Attenuation: %0.2f dB \n', 20 * log( options.tempFilter.attenuation) )
        fprintf('    Band pass Ripple: %0.2f dB \n', 20 * log( options.tempFilter.ripple ) )
        
        fprintf(' Spatial filters:\n')
        fprintf('    Num. filters: %d\n', options.spatialFilter.m );
end

%% Temporal filter design
model.tempFilter = tempFilterDesign(options.tempFilter);

%% Artifact removing
if options.artifactSelection
    EEGdata.eeg = EEGdata.eeg(EEGdata.validTrial == 1,:,:,:);
    EEGdata.trueLabel = EEGdata.trueLabel(1, EEGdata.validTrial == 1);
    EEGdata.validTrial = EEGdata.validTrial(1, EEGdata.validTrial == 1);
    EEGdata.nTrials = size(EEGdata.eeg, 1);
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

model.spatialFilter = NaN(Nchannels, NspatialFilters, NtempFilters, Nsegments);
extractedFeatures = NaN(Nfeatures, Nsegments, Ntrials);
reverseStr = '';

for l = 1:Nsegments    
    featureMatrix = NaN(Nfeatures, Ntrials);
    for j = 1:NtempFilters        
        % s = window x Nchannels
        s = squeeze(eeg_band(:,1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:,j));
        
        % Computing Spatial Covariances Matrices
        scms = SCM(s);
        
        % Store mean covariance matrices
        for c = 1:Nclasses
            model.C(c,:,:,j,l) = mean(scms(EEGdata.trueLabel == c,:,:),1);
        end
        model.Cmean(:,:,j,l) = squeeze( mean(scms, 1) );
        
        % Computing Spatial filters - One versus rest
        W = NaN(Nchannels, NspatialFilters);
        for c = 1:Nclasses
            aux = csp( scms(EEGdata.trueLabel == c,:,:), ...
                scms(EEGdata.trueLabel ~= c,:,:), m);
            W( :, (2*m*(c-1)+1) : 2*m*c ) = aux;
        end
        
        % Save spatial filters at temporal filter j and segment l
        model.spatialFilter(:,:,j,l) = W;
        
        % Spatial filtering and features extraction
        spatialFilteredEEG = [];
        for i = 1:Ntrials
            aux = W' * ( squeeze(scms(i,:,:)) ) * W;
            extr_feat_class = log(diag(aux) / trace(aux));
            spatialFilteredEEG = cat(2, spatialFilteredEEG, extr_feat_class);
        end        
        
        % Save feature vector
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

% Ouput
features.data = extractedFeatures;
features.trueLabel = EEGdata.trueLabel;
features.validTrial = EEGdata.validTrial;
end
