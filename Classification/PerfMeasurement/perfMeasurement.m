function perf = perfMeasurement(prediction, labels, method)
    Nsegments = size(prediction,2);
    perf = [];
    
    if strcmp(method,'acc') == 1
        acc = NaN(Nsegments,1);
        for p = 1:Nsegments
             [~,~,~,~,acc(p,1)] = kappa(labels, prediction(:,p));
        end
        fprintf('\tACC: %.4f \n',max(acc))
        perf.acc = acc;
    end
    
    if strcmp(method,'kappa') == 1
        kap = NaN(Nsegments,1);
        for p = 1:Nsegments
             kap(p,1) = kappa(labels, prediction(:,p));
        end
        fprintf('\tKappa: %.4f \n',max(kap))
        perf.kappa = kap;
    end
    
    if strcmp(method,'mi') == 1
        mi = NaN(Nsegments,1);
        for p = 1:Nsegments
             [~,~,~,~,~,~,mi(p,1)] = kappa(labels, prediction(:,p));
        end
        fprintf('\tMI: %.4f \n',max(mi))
        perf.mi = mi;
    end
    
    if strcmp(method,'H') == 1
        Nclasses = length(unique(prediction(~isnan(prediction))));
        H = NaN(Nsegments,Nclasses,Nclasses);
        for p = 1:Nsegments
             [~,~,H(p,:,:)] = kappa(labels, prediction(:,p));
        end
        perf.H = H;
    end
    
    if strcmp(method, 'all') == 1
        Nclasses = length( unique(labels) );
        acc = NaN(Nsegments,1);
        kap = NaN(Nsegments,1);
        mi = NaN(Nsegments,1);
        H = NaN(Nsegments,Nclasses,Nclasses);
        
        for p = 1:Nsegments
             [kap(p,1),~,H(p,:,:),~, acc(p,1),~,mi(p,1)] = kappa(labels, prediction(:,p));
        end
        fprintf('\tACC: %.4f ',max(acc))
        fprintf('\tKappa: %.4f ',max(kap))
        fprintf('\tMI: %.4f ',max(mi))
        fprintf('\n');
        
        perf.acc = acc;
        perf.kappa = kap;
        perf.H = H;
        perf.mi = mi;
    end
end