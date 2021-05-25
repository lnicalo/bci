%% Motor imagery - BCI
%% Performance Summary
rootPath = '../../02Data/';
dataset = 'competIVdatasetIIa10foldCV';
measure = 'kappa';
fig_number = 1;
decimals = 3; % Number of decimals
time = [2,7.5];

inputFiles = {
    'FBCSP_MIBIF_AdaptLDA_static_temp'
    'FBCSP_MIBIF_AdaptSLDA_static_temp'
    };

Nmodels = length(inputFiles);

close all
dataset_mean_perf = [];

%% Group variable
[a,b] = regexp(dataset, '[0-9][0-9]foldCV');
CV = str2double(dataset(1,a:a+1));

for model = 1:Nmodels
    %% Read file 
    nameFile = sprintf('%s%s/results/%s', rootPath, dataset, inputFiles{model,1});
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'performance', 'ID', 'nameSubjects');
    
    Nsubjects = size(performance, 2);
    Nsamples  = size(performance{1,1}.acc,1);
    perf = NaN(Nsubjects, Nsamples);

    for j = 1:Nsubjects
        perf(j,:) = performance{1,j}.(measure);
    end   
    fprintf('done\n');
    fprintf('Loaded %s model results\n', ID);
    
    %% Average CV subjects
    Nsubjects = Nsubjects / CV;
    perf = reshape( perf, [CV Nsubjects Nsamples]);
    perf = squeeze( mean(perf,1) );
    
    % Mean performance 
    mean_perf = mean(perf, 1);
    dataset_mean_perf(:,model) = mean_perf;
    
    % Plot subject
    plot_subj = figure;
    for subject = 1:Nsubjects
        
        figure(plot_subj)
        subplot(ceil(Nsubjects / 2), 2, subject)
        t = linspace(time(1), time(2), size(perf(subject, :), 2));
        plot(t, perf(subject, :))
        xlabel('Time');
        ylabel('Kappa'); 
        xlim([min(t) max(t)])
        ylim([0 1])
        title(regexprep(nameSubjects{1,(subject - 1) * CV + 1},'CV[0-9][0-9].mat',''))
    
    end
   
    set(gcf,'Name', [dataset ': ' inputFiles{model,1} ' : Subjects'], 'NumberTitle','off');
    
       
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