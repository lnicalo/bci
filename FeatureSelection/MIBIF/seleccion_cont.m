% Archivo de entrada: def_extracted_features_fbcsp_subject%i.mat
% Archivo de salida:  sel_extracted_features_fbcsp_subject%i.mat

% Para cada instante de tiempo selecciona las caracteristicas de entrenamiento 
% de acuerdo a la informacion mutua
Nsubjects = 90;

dir = 'fbcsp/ovrCV';
for subject=1:Nsubjects
    % Cargamos datos
    fprintf('Procesando subject:%i\n',subject);
    
    % Cargamos el archivo donde estan las propiedades
    namefile = sprintf('../../../02mat_files/extracted_features/%s/subject%i.mat',dir,subject);
    load(namefile);
    
    % Cargamos el archivo de la informacion mutua
    namefile = sprintf('../../../02mat_files/extracted_features/%s/I_subject%i.mat',dir,subject);
    load(namefile);
    
    [A, ind] = sort(max(I,[],2),'descend');
    
    Nsamples = size(extracted_features,2);
    NTrials = size(extracted_features,3);
    
    Nfeatures = size(ind,1);
    sel_extracted_features = extracted_features(ind(1:Nfeatures,1),:,:);
    
    extracted_features = sel_extracted_features;
    
    % Archivo que contiene las propiedades seleccionadas
    namefile = sprintf('../../../02mat_files/extracted_features/%s/sel_cont_subject%i',dir,subject);
    save(namefile,'q','spatial_filters','extracted_features','validTrials','fs','overlap','win','labels')
end