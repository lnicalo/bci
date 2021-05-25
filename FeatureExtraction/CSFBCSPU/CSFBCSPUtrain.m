% FBCSP
function [features, model] = CSFBCSPUtrain(EEGdata, EEGdataCS, options)
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
    options.overlap = 2*EEGdata.fs - 10;
end

% Temporal filtering options
if ~isfield(options, 'tempFilter')
    options.tempFilter = [];
end

if ~isfield(options.tempFilter, 'freqBands')
    % 4 - 8, 8 - 12, ..., 36 - 40 Hz
    % options.tempFilter.freqBands = [4 8;8 12;12 16;16 20;20 24;24 28;28 32;32 36;36 40];
    options.tempFilter.freqBands = [4 30];
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

% Adaptation?
if ~isfield(options, 'adapt')
    options.adapt = true;
end

% Artifact selection?
if ~isfield(options, 'artifactSelection')
    options.artifactSelection = true;
end

% Display options
% Default Moderate display level 1
if ~isfield(options, 'display');
    options.display = 1;
end

model = [];
model.ID = 'CSFBCSPU';
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

Nsubjects = size(EEGdataCS, 1);
%% Artifact removing
if options.artifactSelection
    for i = 1:Nsubjects
        EEGdataCS{i,1}.eeg = EEGdataCS{i,1}.eeg(EEGdataCS{i,1}.validTrial == 1,:,:,:);
        EEGdataCS{i,1}.trueLabel = EEGdataCS{i,1}.trueLabel(1, EEGdataCS{i,1}.validTrial == 1);
        EEGdataCS{i,1}.validTrial = EEGdataCS{i,1}.validTrial(1, EEGdataCS{i,1}.validTrial == 1);
        EEGdataCS{i,1}.nTrials = size(EEGdataCS{i,1}.eeg, 1);
    end
end

%% Filtering EEG
Ntrials = EEGdata.nTrials;
NtempFilters = size(options.tempFilter.freqBands, 1);
Nsamples = size(EEGdata.eeg, 2);
Nchannels = size(EEGdata.eeg, 3);

eeg_band = NaN(Ntrials, Nsamples, Nchannels, NtempFilters);
reverseStr = '';
eeg = EEGdata.eeg;

for i = 1:Ntrials % Trials
    for j = 1:Nchannels % Channels
        for k = 1:NtempFilters % Filters
            eeg_band(i,:,j,k) = conv(squeeze(eeg(i,:,j)), model.tempFilter{1,k},'same');
        end
    end
    
    if options.display > 0
        percentDone = 100 * i / Ntrials;
        msg = sprintf('Temporal filtering: %3.1f\n', percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    
    EEGdata.eeg = eeg_band;
end

%% Filtering Cross subject EEG
reverseStr = '';
for u = 1:Nsubjects
    Ntrials_u = EEGdataCS{u, 1}.nTrials;
    
    eeg_band = NaN(Ntrials_u, Nsamples, Nchannels, NtempFilters);
        
    eeg = EEGdataCS{u, 1}.eeg;
    for i = 1:Ntrials_u % Trials
        for j = 1:Nchannels % Channels
            for k = 1:NtempFilters % Filters
                eeg_band(i,:,j,k) = conv(squeeze(eeg(i,:,j)), model.tempFilter{1,k},'same');
            end
        end
        
        if options.display > 0
            percentDone = 100 * i / Ntrials_u;
            msg = sprintf('Temporal filtering (subject %i): %3.1f\n', u, percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
    
    EEGdataCS{u, 1}.eeg = eeg_band;
end
clear eeg_band eeg;

%% Spatial filtering
window = options.window;
overlap = options.overlap;
Nsegments = length(window:(window-overlap):Nsamples);


Nclasses = length(unique(EEGdata.trueLabel(~isnan(EEGdata.trueLabel))));
m = options.spatialFilter.m;
NspatialFilters = Nclasses * 2 * m;
Nfeatures = NtempFilters * NspatialFilters * Nsubjects;
NfeaturesCS = NtempFilters * NspatialFilters;

model.spatialFilter = NaN(Nchannels, NspatialFilters, NtempFilters, Nsegments, Nsubjects);
extractedFeatures = NaN(Nfeatures, Nsegments, Ntrials);
extractedFeaturesCS = cell(Nsubjects, 1);

reverseStr = '';

for u = 1:Nsubjects
    EEGdataCS_u = EEGdataCS{u, 1};
    NtrialsCS = EEGdataCS_u.nTrials;

    featureMatrixCS = NaN(NfeaturesCS, Nsegments, NtrialsCS);
    for l = 1:Nsegments       
        for j = 1:NtempFilters
            %% Target subject SCMs
            % s = window x Nchannels
            s = squeeze(EEGdata.eeg(:,1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:,j));
            
            % Computing Spatial Covariances Matrices
            scms = SCM(s);           
                        
            %% Source subjects SCMs
            % s = window x Nchannels
            s = squeeze( EEGdataCS_u.eeg(:, 1+(l-1)*( ...
                window-overlap):window+(l-1)*(window-overlap),:,j) );
            
            % Computing Spatial Covariances Matrices
            scmsCS = SCM(s);             
            
            if options.adapt
                % Mean covariance matrices
                C = squeeze( mean( scms, 1) );
                
                % Mean covariance matrices
                C_SC = squeeze( mean(scmsCS, 1) );
                
                % Compute linear transformation
                V = round(C_SC^-0.5 * C^0.5 * 10^8)/10^8;
                for i = 1:NtrialsCS
                    scmsCS(i,:,:) = V'*squeeze(scmsCS(i,:,:))*V;
                end
            end
            
            %% CSP
            % Computing Spatial filters - One versus rest
            W = NaN(Nchannels, NspatialFilters);
            for c = 1:Nclasses
                aux = csp( scmsCS(EEGdataCS_u.trueLabel == c,:,:), ...
                    scmsCS(EEGdataCS_u.trueLabel ~= c,:,:), m);
                W( :, ( (2*m*(c-1)+1) : 2*m*c ) ) = aux;
            end
            
            % Save spatial filters at temporal filter j and segment l
            model.spatialFilter(:,:,j,l,u) = W;
            
            %% Feature extraction
            % Feature extraction target subject
            spatialFilteredEEG = NaN(NspatialFilters, Ntrials);
            for i = 1:Ntrials
                aux = W' * ( squeeze(scms(i,:,:)) ) * W;
                spatialFilteredEEG(:, i) = log(diag(aux) / trace(aux));
            end
            
            % Save feature vector
            extractedFeatures( ...
                ((NspatialFilters*j - (NspatialFilters-1)) : NspatialFilters*j) + (u-1)*NspatialFilters*NtempFilters, l, :) = spatialFilteredEEG;
            
            % Feature extraction source subject
            spatialFilteredEEG = NaN(NspatialFilters, NtrialsCS);
            for i = 1:NtrialsCS
                aux = W' * ( squeeze(scmsCS(i,:,:)) ) * W;
                spatialFilteredEEG(:, i) = log(diag(aux) / trace(aux));
            end
            
            % Save feature vector - Cross Subjects
            featureMatrixCS( ...
                ((NspatialFilters*j - (NspatialFilters-1)) : NspatialFilters*j),l, :) ...
                = spatialFilteredEEG;
        end % NtempFilters
        
        % Display progress
        if options.display > 0
            percentDone = 100 * l / Nsegments;
            msg = sprintf('Spatial filtering (Subject %i): %3.1f\n', u, percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end  % Nsegments
    
   % Save feature source subjects
    extractedFeaturesCS{u, 1} = permute(featureMatrixCS,[3 2 1]);   
end % Nsubjects

if options.display > 0
    fprintf('\n')
end

extractedFeatures = permute(extractedFeatures,[3 2 1]);

% Ouput
features.data = extractedFeatures;
features.trueLabel = EEGdata.trueLabel(1, :);
features.validTrial = EEGdata.validTrial(1, :);
features.dataCS = [];
features.dataCS.data = extractedFeaturesCS;
features.dataCS.trueLabel = cell(Nsubjects, 1);
features.dataCS.validTrial = cell(Nsubjects, 1);

for i = 1:Nsubjects
    features.dataCS.trueLabel{i,1} = EEGdataCS{i, 1}.trueLabel(1,:);
    features.dataCS.validTrial{i, 1} =  EEGdataCS{i, 1}.validTrial(1,:);
end

end
