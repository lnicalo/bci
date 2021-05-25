% Archivo de entrada: 
%       1. Para cargar la informacion mutua de las propiedades de entrenamiento
%               def_extracted_features_fbcsp_subject%i.mat
%       2. Para cargar las propiedades de test:
%               def_extracted_features_test_fbcsp_subject%i.mat
% Archivo de salida:  sel_extracted_features_fbcsp_subject%i.mat

% Para cada instante de tiempo selecciona las caracteristicas de test 
% de acuerdo a la informacion mutua

dir = 'fbcsp/ovrLOO';
Nsubjects = 9;
n_test =[    92    97    13    75    66    32    97    83    41];
n_test = ones(Nsubjects,1)*n_test;
n_test = n_test(:);
for subject=1:Nsubjects
    fprintf('Procesando subject:%i\n',subject);
    
    % Cargamos datos
    % Cargamos las propiedades
    namefile = sprintf('../../../02mat_files/extracted_features_test/%s/subject%i.mat',dir,subject);
    load(namefile)
    % Cargamos el archivo de la informacion mutua
    namefile = sprintf('../../../02mat_files/extracted_features/%s/I_subject%i.mat',dir,subject);
    load(namefile);
    
    
    
    [A ind] = sort(I,'descend');
    
    Nsamples = size(extracted_features,2);
    NTrials = size(extracted_features,3);
    
    % Se seleccionan aquellas con mayor informacion mutua
    [i,j] = max(mean(I,1));
    Nfeatures = sum(I(:,j) > (A(1,j)/2));
    % Nfeatures = n_test(Nsubjects,1);
    Nfeatures = 144;
    sel_extracted_features = NaN(Nfeatures,Nsamples,NTrials);
    
        
    for i=1:Nsamples        
        sel_extracted_features(:,i,:) = extracted_features(ind(1:Nfeatures,i),i,:);
    end
    
    extracted_features = sel_extracted_features;
    
    namefile = sprintf('../../../02mat_files/extracted_features_test/%s/sel_subject%i.mat',dir,u);
    save(namefile,'u','trueLabel','validTrial','fs','win','overlap','extracted_features')
end