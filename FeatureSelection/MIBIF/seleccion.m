% Archivo de entrada: def_extracted_features_fbcsp_subject%i.mat
% Archivo de salida:  sel_extracted_features_fbcsp_subject%i.mat

% Para cada instante de tiempo selecciona las caracteristicas de entrenamiento 
% de acuerdo a la informacion mutua
Nsubjects = 9;

dir = 'fbcsp/ovrLOO';
n_test =[    92    97    13    75    66    32    97    83    41];
n_test = ones(Nsubjects,1)*n_test;
n_test = n_test(:);
for subject=1:Nsubjects
    % Cargamos datos
    fprintf('Procesando subject:%i\n',subject);
    
    % Cargamos el archivo donde estan las propiedades
    namefile = sprintf('../../../02mat_files/extracted_features/%s/subject%i.mat',dir,subject);
    load(namefile);
    
    % Cargamos el archivo de la informacion mutua
    namefile = sprintf('../../../02mat_files/extracted_features/%s/I_subject%i.mat',dir,subject);
    load(namefile);
    
    [A ind] = sort(I,1,'descend');
    
    Nsamples = size(extracted_features,2);
    NTrials = size(extracted_features,3);
    
    % Se seleccionan aquellas con mayor informacion mutua
    % Numero de propiedades que se desea despues de la seleccion
    % [i,j] = max(mean(I,1));
    % Nfeatures = sum(I(:,j) > (A(1,j)/2));
    Nfeatures = 144;
    
    sel_extracted_features = NaN(Nfeatures,Nsamples,NTrials);
    for i=1:Nsamples
        sel_extracted_features(:,i,:) = extracted_features(ind(1:Nfeatures,i),i,:);
    end
    
    extracted_features = sel_extracted_features;
    
    % Archivo que contiene las propiedades seleccionadas
    namefile = sprintf('../../../02mat_files/extracted_features/%s/sel_subject%i',dir,subject);
    save(namefile,'q','spatial_filters','extracted_features','validTrials','fs','overlap','win','labels')
end