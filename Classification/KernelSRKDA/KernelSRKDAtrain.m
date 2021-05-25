function model = KernelSRKDAtrain(features, options)

    if ~exist('options', 'var')
        options = [];
    end
    
    if ~isfield(options,'Regu')
        % Reguralization
        options.Regu = 10;
    end
    
    
    % Display options
    % Default Moderate display level 1
    if ~isfield(options,'display')
        % Display
        options.display = 1;
    end
    
    model = [];
    model.ID = 'KernelSRKDA';
    model.options = options;    
    
    % Training
    Ntrials = size(features.data, 1);
    Nsamples = size(features.data, 2);
    Nobjects  = size(features.data, 3);
    
    model.classifier = cell(Nobjects, Nsamples);
    model.trainfea = features.data;
    for m = 1:Nsamples
        F = squeeze( features.data(:, m,:,:,:) );
        
        % Computing multikernel
        reverseStr = '';
        for i = 1:Nobjects            
            FO = squeeze( F(:, i,:) );
            K = real( FO * FO' );
            
            % Normalizing
            D = diag(1./sqrt(diag(K)));
            K = D * K * D;                    
            
            % Train SVM
            model.classifier{i, m} = svmtrain(features.trueLabel', [(1:Ntrials)', K],sprintf('-c %f -q -t 4', options.Regu));
        end
        
        if options.display > 0
            percentDone = 100 * m / Nsamples;
            msg = sprintf('Training: %3.1f\n', percentDone);
            fprintf([reverseStr, msg]);
            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
    end
end