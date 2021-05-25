function perf = perfMeasurementUnb(prediction, labels, method, balance)
    classes = unique(labels);
    perf = cell(length(balance), 1);
    
    for b = 1:length(balance) 
        % find index with class equals to first class
        ind1 = find(labels == classes(1));
        
        % index to remove
        rm_trials = round( balance(b)/100 * length(ind1) );
        rm_ind1 = ind1(end - rm_trials+1:end);
        
        % removing
        labels_b = labels;
        prediction_b = prediction;
        labels_b(rm_ind1) = [];
        prediction_b(rm_ind1,:) = [];
        
        % compute performance
        perf_b = perfMeasurement(prediction_b, labels_b, method);
        
        % save perf
        perf{b, 1} = perf_b;
    end
end