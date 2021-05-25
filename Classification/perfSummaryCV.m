%% Motor imagery - BCI
%% Performance Summary Cross validation
rootPath = '../../02Data/';
dataset = 'competIVdatasetIIa10foldCV';
extrFeatAlg = 'FBCSP';
featSelAlg = 'MIBIF';
classificationAlg = 'AdaptEMLDA';
% classificationAlg = 'AdaptSLDA';
params = {'F'};
% params = {'ReguAlpha'};
% params = {'ReguAlpha', 'W'};
measure = 'kappa';

fig_number = 1;
decimals = 3; % Number of decimals
report = true;

close all
%% Heading
disp(['Cross Validation: ' dataset])

%% Group variable
[a,b] = regexp(dataset, '[0-9][0-9]foldCV');
CV = str2double(dataset(1,a:a+1));

%% Read file
nameFile = sprintf('%s%s/resultsCV/%s_%s_%s', rootPath, dataset, extrFeatAlg, featSelAlg, classificationAlg);
nameFile = strcat(nameFile, sprintf('_%s', params{:}));
load(nameFile, 'performance', 'ID', 'nameSubjects','L','Lparam','CV_param');

Nsubjects = size(performance, 2);
Nsamples  = size(performance{1,1}.acc,1);
perf = NaN(L, Nsubjects, Nsamples);
for i = 1:L
    for j = 1:Nsubjects
        perf(i,j,:) = performance{i,j}.(measure);
    end
end

%% Max across time (competition)
Nsubjects = Nsubjects / CV;
perf = reshape(permute(perf,[2 1 3]),[CV Nsubjects L Nsamples]);
perf = permute( squeeze( mean(perf,1) ), [2 1 3]);
perf_max = squeeze( max(perf, [], 3) );

%% Mean across subjects
perf_mean = mean(perf_max, 2);

%% Print out the best parameters
[sel_perf, ind] = max(perf_mean);
for j = 1:length(Lparam)
    fprintf('%s: %.2f \t%', params{1, j}, CV_param(ind, j));
end
fprintf('%s: %.02f\n', measure, sel_perf);

%% Plot
for j = 1:length(Lparam)
    plot1 = figure;
    for i = 1:Nsubjects
        perf_max_u = perf_max(:, i);
        
        if length(Lparam) > 1
            perf_max_u = reshape(perf_max_u, Lparam');
        end
        
        perf_max_u_j = perf_max_u;
        for k = setdiff(1:length(Lparam), j)
            perf_max_u_j = max(perf_max_u_j, [], k);
        end
        ax = sort(unique( CV_param(:, j) ));  
        
        figure(plot1)
        subplot(ceil((Nsubjects + 1)/ 2), 2, i)
        plot(ax, perf_max_u_j' )
        axis tight
        title(regexprep(nameSubjects{1,(i - 1) * CV + 1},'CV[0-9][0-9].mat',''))
    end
    
    % Plot mean
    if length(Lparam) > 1
        perf_mean = reshape(perf_mean, Lparam');   
    end
    
    perf_mean_j = perf_mean;
    for k = setdiff(1:length(Lparam), j)
        perf_mean_j = max(perf_mean_j, [], k);
    end
    ax = sort(unique( CV_param(:, j) ));
       
    figure(plot1)
    subplot(ceil((Nsubjects + 1)/ 2), 2, Nsubjects + 1)
    plot(ax, perf_mean_j)
    axis tight
    title('Mean')
    
    set(gcf,'Name', [measure ' -- ', params{1, j}], 'NumberTitle','off');
    
    if report
        plot2 = figure;
        plot(ax, perf_mean_j)
        axis tight
        title('Mean', 'FontSize',24)
        xhandle = xlabel(params{1, j});
        yhandle = ylabel(measure);
        set(xhandle,'FontSize',24)
        set(yhandle,'FontSize',24)
        set(gca,'FontSize',24)
        set(gcf,'Name', [measure ' report -- ', params{1, j}], 'NumberTitle','off');
    
        % Save figure as .eps
        nameFig = sprintf('%s%s/resultsCV/%s_%s_%s', rootPath, dataset, extrFeatAlg, featSelAlg, classificationAlg);
        nameFig = strcat(nameFig, sprintf('_%s', params{:}));
        nameFig = strcat(nameFig, sprintf('-%s', params{1, j}));
        saveas(gca, nameFig, 'eps');
    end
        
end%% Max across time (competition)


%% Real BCI performance
%% Mean across subjects
perf_mean = squeeze( mean(perf, 2) );

%% Max. mean performance
[perf_max, ind_time] = max(perf_mean, [], 2);

%% Print out the best parameters
[sel_perf, ind] = max(perf_max);

for j = 1:length(Lparam)
    fprintf('%s: %.2f \t%', params{1, j}, CV_param(ind, j));
end
fprintf('%s: %.03f Time: %i\n', measure, sel_perf, ind_time(ind));

%% Plot
offset = length(Lparam);
for j = 1:length(Lparam)
    plot1 = figure;
    for i = 1:Nsubjects
        perf_u = diag( squeeze( perf(:, i, ind_time)) );
        
        if length(Lparam) > 1
            perf_u = reshape(perf_u, Lparam');
        end
        
        perf_max_u_j = perf_u;
        for k = setdiff(1:length(Lparam), j)
            perf_max_u_j = max(perf_max_u_j, [], k);
        end
        ax = sort(unique( CV_param(:, j) ));       
        
        figure(plot1)
        subplot(ceil((Nsubjects + 1)/ 2), 2, i)
        plot(ax, perf_max_u_j )
        axis tight
        title(regexprep(nameSubjects{1,(i - 1) * CV + 1},'CV[0-9][0-9].mat',''))
    end
    
    % Plot mean
    if length(Lparam) > 1
        perf_max = reshape(perf_max, Lparam');   
    end
    
    perf_mean_j = perf_max;
    for k = setdiff(1:length(Lparam), j)
        perf_mean_j = max(perf_mean_j, [], k);
    end
    ax = sort(unique( CV_param(:, j) ));
        
    subplot(ceil((Nsubjects + 1)/ 2), 2, Nsubjects + 1)
    plot(ax, perf_mean_j)
    axis tight
    title('Mean')
    
    set(gcf,'Name', [measure ' mean -- ', params{1, j}], 'NumberTitle','off');

    if report
        plot2 = figure;
        plot(ax, perf_mean_j)
        title('Mean', 'FontSize',24)
        xhandle = xlabel(params{1, j});
        yhandle = ylabel(measure);
        set(xhandle,'FontSize',24)
        set(yhandle,'FontSize',24)
        set(gca,'FontSize',24)
        set(gcf,'Name', [measure ' mean report -- ', params{1, j}], 'NumberTitle','off');
        axis tight
        
        % Save figure as .eps
        nameFig = sprintf('%s%s/resultsCV/%s_%s_%s', rootPath, dataset, extrFeatAlg, featSelAlg, classificationAlg);
        nameFig = strcat(nameFig, sprintf('_%s', params{:}));
        nameFig = strcat(nameFig, sprintf('-mean_%s', params{1, j}));
        saveas(gca, nameFig, 'eps');
    end
end
