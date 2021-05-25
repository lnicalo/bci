% fast Affinity Propagation clustering to find an exact K
% Kaijun WANG, wangkjun@yahoo.com, Oct. 2009.

clear;
id = 1;        % selecting a data set, rows - data points, columns - dimensions
fastAP = 0;    % 1 --- fast AP, 0 --- original AP
K = 3;         % finding K clusters exactly
nrun = 2000;   % max iteration times, default 2000
nconv = 200;   % convergence condition, default 200
lam = 0.9;     % damping factor, default 0.9 (necessary to avoid oscillations)
splot = 'plot'; % observing a clustering process when splot = 'plot'

type = 1;       % 1: Euclidean distances; 2: Pearson correlation coefficients
alabel = 1;     % 1: true labels in 1st column; 0: no label, all are data
simatrix = 0;   % 0: data as input; 1: similarity matrix as input
aready = 0;     % data and truelabels are ready when *.mat is loaded
nrow = 0;

switch id
  case 1
     sw='iris.txt';               % true NC=3
  case 2
     sw='5k8close.txt';    K=5;    % true NC=5
  case 3
     sw='22k10far.txt';    K=22;   % true NC=22
  case 4
     sw='colon2000_4k62.txt'; alabel = 0; K=4; type = 2;     
  case 5
     sw='FaceClusteringSimilarities.txt'; 
     simatrix = 1; alabel = 0; nrow = 900; K = 100;
end

if ~aready
    [M,truelabels,nrow] = data_load(sw,alabel,nrow,simatrix);
else
    load(sw); 
end

disp(' '); disp(['==> Clustering is running on ' sw ',']);
if ~simatrix
    [M,pmedian] = simatrix_ap(M,type,0);
end

% finding K clusters exactly
tic;
if fastAP
    disp(['    and trying to find ' int2str(K) ' clusters by fastAP !']);
    % finding preference bounds: lowp & highp
    [labelid,netsim,dpsim,expref,pref,lowp,highp]=apclusterK_fast2(M,1,0);
    for i = 1:length(K)
        [labelid(:,i),netsim,dpsim,expref,pref]=apclusterK_fast2(...
            M,K(i),0,nrun,nconv,lam,splot,lowp,highp,nrow);
    end
else
    disp(['    and trying to find ' int2str(K) ' clusters by existAP !']);
    for i = 1:length(K)
        [labelid(:,i),netsim,dpsim,expref,pref]=apclusterK(M,K(i),0);
    end
end
trun = toc;
fprintf('\n## Running time = %g seconds \n', trun);

[C, label] = ind2cluster(labelid);

fprintf('\n## Error rate of clustering solution might be inaccurate if large');
fprintf('\n     (then use FM index instead) and it is for reference only:');
valid_errorate(label, truelabels);

C = valid_external(label, truelabels);
fprintf('Fowlkes-Mallows validity index: %f\n', C(4));
% save('solution','truelabels','label','labelid','C');
