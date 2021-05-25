% Improved programs of Affinity Propagation clustering;
% original Affinity Propagation (see Frey & Dueck, Science, Feb. 2007)
% Note: Statistics Toolbox of Matlab needs to be installed
% Kaijun WANG: sunice9@yahoo.com, April 2007.

clear;
alg = 1;      % 1 --- Improved AP, 0 --- original AP
type = 1;   % 1 - using Euclidean distances for general data;
% 2 - Pearson correlation coefficients for gene data (see row 35)

% selecting a data set, rows - data points, columns - dimensions
id = 1;

switch id
%(1) general simulated data, Euclidean distances, true labels in 1st column
  case 1
     sw='4k2_far.txt';  % true number of clusters is 4
  case 2
     sw='yourdata.txt';

  case 11           % true labels being unknown (1st column is data too)
     sw='yourdata.txt'; 
     
    
%(2) real gene data, Pearson distances, true labels in 1st column
  case 21
     sw='leuk72_3k.txt';  % true number of clusters is 3
  case 22
     sw='yourdata.txt'; %

  case 31            % true labels being unknown (1st column is data too)
     sw='yourdata.txt'; 
end

% initialization
if id > 20
   type = 2;
end
data = load(sw);
[nrow, dim] = size(data);
truelabels = ones(nrow,1);
if id < 11 || (id > 20 && id < 30)  % when 1st column is class labels
   truelabels = data(:,1); 
   data = data(:,2:dim);
   dim = dim-1;
end

if type == 1
   [Dist, dmax] = similarity_euclid(data,2);
   R = 'euclidean';  
else
   Dist = 1-(1+similarity_pearson(data'))/2;
   dmax = 1;
   R = 'correlation';
end

nap = nrow*nrow-nrow;
M = zeros(nap,3);
j=1;
for i=1:nrow
   for k = [1:i-1,i+1:nrow]
     M(j,1) = i;
     M(j,2) = k; 
     M(j,3) = -Dist(i,k);
     j = j+1;
   end;
 end;
Dist = [];

p = median(M(:,3));                     % Set preference to median similarity
pmin = -dmax;
pstep = pmin*0.1;                       % decreasing step of p


disp(' '); disp('==> Clustering is running, please wait ...');
if alg
  [label,NC,Sil] = apcluster_imp(M, p, pstep, pmin, ...
    data, R, 'convits', 300,'maxits',1000,'plot'); %'plot',
  fprintf('\n## Clustering solution by Improved Affinity Propagation:\n');

else
  [label,n,d,e,unconverged] = apcluster(M, p, 'convits', 300, 'maxits',1000);   
  if unconverged
  fprintf('\n*** Dampfact is increased to 0.7, and clustering is re-running ...');
  label = apcluster(M, p, 'convits', 300, 'maxits',1000', 'dampfact', 0.7);
  end
  C = unique(label);
  NC = length(C);
  [C, label] = ind2cluster(label);
  fprintf('$$ Clustering solution by original Affinity Propagation:\n');
end
M = [];

fprintf('Number of clusters is %d\n',NC);
C = valid_external(label, truelabels);
fprintf('Fowlkes-Mallows validity index: %f\n', C(4));
valid_errorate(label, truelabels);