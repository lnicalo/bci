% FBCSP
function [features, model] = CSFBCSPUEtrain(EEGdata, EEGdataCS, options)
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


extractedFeatures = NaN(Nchannels, Nchannels, Ntrials, NtempFilters);
extractedFeaturesCS = cell(Nsubjects, 1);

reverseStr = '';

%% Target subject SCMs
% % s = window x Nchannels
% s = squeeze(EEGdata.eeg(:,1+(l-1)*(window-overlap):window+(l-1)*(window-overlap),:,j));
% 
% % Computing Spatial Covariances
% extractedFeatures(:,:,:,j) = SCM(s);        

for u = 1:Nsubjects
    EEGdataCS_u = EEGdataCS{u, 1};
    NtrialsCS = EEGdataCS_u.nTrials;

    featureMatrixCS = NaN(NtrialsCS, Nchannels, Nchannels, NtempFilters);
    for l = 80       
        for j = 1:NtempFilters              

            %% Source subjects SCMs
            % s = window x Nchannels
            s = squeeze( EEGdataCS_u.eeg(:, 1+(l-1)*( ...
                window-overlap):window+(l-1)*(window-overlap),:,j) );
            
            % Computing Spatial Covariances
            featureMatrixCS(:,:,:,j) = SCM(s);           
        end % NtempFilters
        
        extractedFeaturesCS{u, 1} = featureMatrixCS;        
    end  % Nsegments 
    
    % Display progress
    if options.display > 0
        percentDone = 100 * u / Nsubjects;
        msg = sprintf('Matrix covariances (Subject %i): %3.1f\n', u, percentDone);
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end 
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
