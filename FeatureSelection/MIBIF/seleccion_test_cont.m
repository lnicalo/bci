% Archivo de entrada: 
%       1. Para cargar la informacion mutua de las propiedades de entrenamiento
%               def_extracted_features_fbcsp_subject%i.mat
%       2. Para cargar las propiedades de test:
%               def_extracted_features_test_fbcsp_subject%i.mat
% Archivo de salida:  sel_extracted_features_fbcsp_subject%i.mat

% Para cada instante de tiempo selecciona las caracteristicas de test 
% de acuerdo a la informacion mutua

dir = 'fbcsp/ovrCV';
Nsubjects = 90;
for subject=1:Nsubjects
    fprintf('Procesando subject:%i\n',subject);
    
    % Cargamos datos
    % Cargamos las propiedades
    namefile = sprintf('../../../02mat_files/extracted_features_test/%s/subject%i.mat',dir,subject);
    load(namefile)
    % Cargamos el archivo de la informacion mutua
    namefile = sprintf('../../../02mat_files/extracted_features/%s/I_subject%i.mat',dir,subject);
    load(namefile);
    
    
    
    [A, ind] = sort(max(I,[],2),'descend');
    
    Nsamples = size(extracted_features,2);
    NTrials = size(extracted_features,3);
    
    Nfeatures = size(ind,1);
    sel_extracted_features = extracted_features(ind(1:Nfeatures,1),:,:);

    extracted_features = sel_extracted_features;
    
    namefile = sprintf('../../../02mat_files/extracted_features_test/%s/sel_cont_subject%i.mat',dir,u);
    save(namefile,'u','trueLabel','validTrial','fs','win','overlap','extracted_features')
end