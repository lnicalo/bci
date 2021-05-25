%% Motor imagery - BCI
%% Performance Summary
rootPath = '../../02Data/';
dataset = 'competIVdatasetIIa3_4';
measure = 'acc';
decimals = 2; % Number of decimals


inputTestFiles = {
    'FBCSP_MIBIF_AdaptSLDA_adapt'  
    };

inputCompetitorsFiles = {
    'FBCSP_MIBIF_MPMLDA_static'
    'DSAFBCSP_MIBIF_MPMLDA_static'
    'FBCSP_MIBIF_MPMLDA_equal'
    'FBCSP_MIBIF_AdaptLDA_static'
    'FBCSP_MIBIF_AdaptSLDA_static'
    'FBCSP_MIBIF_AdaptLDA_adapt'   
    };

NtestModels = length(inputTestFiles);

testPerf = [];
for model = 1:NtestModels
    % Load model results
    nameFile = sprintf('%s%s/results/%s', rootPath, dataset, inputTestFiles{model,1});
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'performance', 'ID', 'nameSubjects');
    fprintf('done\n');
    fprintf('Loaded %s model results\n', ID);
    
    Nsubjects = length(performance);
    subject_perf = NaN(Nsubjects, 1);
    
    for subject = 1:Nsubjects
        perf = performance{1, subject};        
        subject_perf(subject, 1) = max( perf.(measure) );
    end
       
    testPerf = cat(2, testPerf, subject_perf);
end


compPerf = [];
NcompModels = length(inputCompetitorsFiles);
for model = 1:NcompModels
    % Load model results
    nameFile = sprintf('%s%s/results/%s', rootPath, dataset, inputCompetitorsFiles{model,1});
    fprintf('Loading ''%s'' ... ', nameFile);
    load(nameFile, 'performance', 'ID', 'nameSubjects');
    fprintf('done\n');
    fprintf('Loaded %s model results\n', ID);
    
    Nsubjects = length(performance);
    subject_perf = NaN(Nsubjects, 1);
    
    for subject = 1:Nsubjects
        perf = performance{1, subject};        
        subject_perf(subject, 1) = max( perf.(measure) );
    end
       
    compPerf = cat(2, compPerf, subject_perf);
end

%% p - values
pvalues = NaN(NcompModels, NtestModels);
for i = 1:NtestModels
    for j = 1:NcompModels
        [pvalues(j,i),y] = signrank( testPerf(:,i), compPerf(:,j), 'tail', 'both' );
    end
end

%% Show mean performnce - Table format
mean_perf = [mean(compPerf) mean(testPerf)];
std_perf = [std(compPerf,1) std(testPerf,1)];
aux = round(10^decimals*[mean_perf' std_perf'])/10^decimals;
dataset_perf = mat2dataset ( aux );
dataset_perf.Properties.ObsNames = cat(1, inputCompetitorsFiles, inputTestFiles);
dataset_perf.Properties.VarNames = {['Mean_' measure], ['STD_' measure]};

disp_performance = strrep(evalc('disp(dataset_perf)'), '_', ' ');
disp(disp_performance)

%% Show p-values performnce - Table format
dataset_perf = [];
dataset_perf = mat2dataset ( pvalues );
dataset_perf.Properties.ObsNames = inputCompetitorsFiles;
dataset_perf.Properties.VarNames = inputTestFiles;

disp_performance = strrep(evalc('disp(dataset_perf)'), '_', ':');
disp(disp_performance)