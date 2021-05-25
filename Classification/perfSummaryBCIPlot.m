%% Motor imagery - BCI
%% Performance Summary
rootPath = '../../02Data/';
dataset = 'competIVdatasetIIa1_2TestRm';
measure = 'kappa';
fig_number = 1;
decimals = 3; % Number of decimals
time = [2,6];

inputFiles = {
    'FBCSP_MIBIF_AdaptLDA_static_temp'
    'FBCSP_MIBIF_AdaptLDA_adapt_temp'
    'FBCSP_MIBIF_AdaptSLDA_static_temp'
    'FBCSP_MIBIF_AdaptSLDA_adapt_temp'
    };

Nmodels = length(inputFiles);

close all
dataset_mean_perf = [];
for model = 1:Nmodels
    % Load model results
    nameFile = sprintf('%s%s/results/%s', rootPath, dataset, inputFiles{model,1});
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'performance', 'ID', 'nameSubjects');
    fprintf('done\n');
    fprintf('Loaded %s model results\n', ID);
    
    Nsubjects = length(performance);

    % Mean performance 
    mean_perf = 0;
    
    plot_subj = figure;
    

    for subject = 1:Nsubjects
        perf = performance{1, subject};        
        subject_perf = perf.(measure);
        
        mean_perf = mean_perf + subject_perf;
        
        % Plot subject
        figure(plot_subj)
        subplot(ceil(Nsubjects / 2), 2, subject)
        t = linspace(time(1), time(2), size(subject_perf,1));
        plot(t, subject_perf)
        xhandle = xlabel('Time');
        yhandle = ylabel('Kappa'); 
        xlim([min(t) max(t)])
        ylim([0 1])
        title(regexprep(nameSubjects{1,subject},'.mat',''))
    
    end
   
    set(gcf,'Name', [dataset ': ' inputFiles{model,1} ' : Subjects'], 'NumberTitle','off');

    mean_perf = mean_perf / Nsubjects;    
    dataset_mean_perf(:,model) = mean_perf;   
end

t = linspace(time(1), time(2), size(dataset_mean_perf,1));
figure
plot(t, dataset_mean_perf)

title('Mean', 'FontSize',24)
xhandle = xlabel('Time');
yhandle = ylabel('Mean kappa');
set(xhandle,'FontSize',24)
set(yhandle,'FontSize',24)
set(gca,'FontSize',24)
xlim([min(t) max(t)])
set(gcf,'Name', [dataset ': Mean kappa'], 'NumberTitle','off');


% Save figure as .eps
nameFig = sprintf('%s%s/results/plot_mean_%s', rootPath, dataset, measure);
saveas(gca, nameFig, 'eps');