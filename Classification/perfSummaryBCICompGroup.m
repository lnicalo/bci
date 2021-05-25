%% Motor imagery - BCI
%% Performance Summary
rootPath = '../../02Data/';
dataset = 'competIVdatasetIIa1_2Test10Rm';
measure = 'acc';

fig_number = 1;
decimals = 3; % Number of decimals

[a,b] = regexp(dataset, '[0-9][0-9]Rm');
Rm = str2double(dataset(1,a:a+1));

inputFiles = dir(sprintf('%s%s/results/*.mat', rootPath, dataset));

Nmodels = length(inputFiles);

dataset_perf = [];

for model = 1:Nmodels
    % Load model results
    nameFile = sprintf('%s%s/results/%s', rootPath, dataset, inputFiles(model,1).name);
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'performance', 'ID', 'nameSubjects');
    fprintf('done\n');
    fprintf('Loaded %s model results\n', ID);
    
    NsubjectsRm = size(performance, 2);
    Nsamples  = size(performance{1,1}.acc,1);
    perf = NaN(NsubjectsRm, Nsamples);

    for j = 1:NsubjectsRm
        perf(j,:) = performance{1,j}.(measure);
    end

    %% Average CV subjects
    Nsubjects = NsubjectsRm / Rm;
    perf = reshape( perf, [Rm Nsubjects Nsamples]);
    perf = squeeze( mean(perf, 2) );
    
    
    
    dataset_perf(:, model) = perf;
end

close all
figure
plot(dataset_perf)
axis tight
title('Mean', 'FontSize',24)
xhandle = xlabel('Balance');
yhandle = ylabel('Mean kappa');
set(xhandle,'FontSize',24)
set(yhandle,'FontSize',24)
set(gca,'FontSize',24)
set(gcf,'Name', [dataset ': Mean kappa'], 'NumberTitle','off');

for i = 1:Nmodels
    inputFiles(i,1).name = strrep(inputFiles(i,1).name, '.mat', '');
    inputFiles(i,1).name = strrep(inputFiles(i,1).name, '_', ':');
end
% legend(inputFiles(:,1).name)