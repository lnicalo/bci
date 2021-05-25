function [labels,NC,Sil,netsim,dpsim,expref] = ...
    apcluster_imp(s, pcut, pstep, pmin, data, dtype, varargin)

% Handle arguments to function
if nargin<2
    error('Too few input arguments');
else
    maxits=500; convits=50; lam=0.5; plt=0; details=0; nonoise=0;
    i=1;
    while i<=length(varargin)
        if strcmp(varargin{i},'plot')
            plt=1; i=i+1;
        elseif strcmp(varargin{i},'details')
            details=1; i=i+1;
		elseif strcmp(varargin{i},'sparse')
			[idx,netsim,dpsim,expref]=apcluster_sparse(s,pcut,varargin{:});
			return;
        elseif strcmp(varargin{i},'nonoise')
            nonoise=1; i=i+1;
        elseif strcmp(varargin{i},'maxits')
            maxits=varargin{i+1};
            i=i+2;
            if maxits<=0 
                error('maxits must be a positive integer'); 
            end;
        elseif strcmp(varargin{i},'convits')
            convits=varargin{i+1};
            i=i+2;
            if convits<=0
                error('convits must be a positive integer'); 
            end;
        elseif strcmp(varargin{i},'dampfact')
            lam=varargin{i+1};
            i=i+2;
            if (lam<0.5)||(lam>=1)
                error('dampfact must be >= 0.5 and < 1');
            end;
        else i=i+1;
        end;
    end;
end;

if lam>0.9
    fprintf('\n*** Warning: Large damping factor in use. Turn on plotting\n');
    fprintf('    to monitor the net similarity. The algorithm will\n');
    fprintf('    change decisions slowly, so consider using a larger value\n');
    fprintf('    of convits.\n\n');
end;

% Check that standard arguments are consistent in size
if length(size(s))~=2 
    error('s should be a 2D matrix');
elseif length(size(pcut))>2 
    error('pcut should be a vector or a scalar');
elseif size(s,2)==3
    tmp=max(max(s(:,1)),max(s(:,2)));
    if length(pcut)==1 
        N=tmp; 
    else
        N=length(pcut);
    end;
    if tmp>N
        error('data point index exceeds number of data points');
    elseif min(min(s(:,1)),min(s(:,2)))<=0
        error('data point indices must be >= 1');
    end;
elseif size(s,1)==size(s,2)
    N=size(s,1);
    if (length(pcut)~=N) && (length(pcut)~=1)
        error('pcut should be scalar or a vector of size N');
    end;
else error('s must have 3 columns or be square'); 
end;

% Construct similarity matrix
if N>3000
    fprintf('\n*** Warning: Large memory request. Consider activating\n');
    fprintf('    the sparse version of APCLUSTER.\n\n');
end;
if size(s,2)==3
    S=-Inf*ones(N,N); 
    for j=1:size(s,1)
        S(s(j,1),s(j,2))=s(j,3); 
    end;
else
    S=s;
end;
s =[];

% In case user did not remove degeneracies from the input similarities,
% avoid degenerate solutions by adding a small amount of noise to the
% input similarities
if ~nonoise
    rns=randn('state'); 
    randn('state',0);
    S=S+(eps*S+realmin*100).*rand(N,N);
    randn('state',rns);
end;

% Place preferences on the diagonal of S
if length(pcut)==1 
    for i=1:N 
        S(i,i)=pcut; 
    end;
else
    for i=1:N 
        S(i,i)=pcut(i); 
    end;
end;

% Allocate space for messages, etc
dS=diag(S); 
A=zeros(N,N); 
R=zeros(N,N); 
t=1;
if plt 
    netsim=zeros(1,maxits+1); 
end;
if details
    idx=zeros(N,maxits+1);
    netsim=zeros(1,maxits+1); 
    dpsim=zeros(1,maxits+1); 
    expref=zeros(1,maxits+1); 
end;


% Execute parallel affinity propagation updates
nrow = size(data,1);
dn=0; i=0; sup =1;
convinput = convits;
Hconv = zeros(N,convinput); 
convits = round(convits/6); 
He = zeros(N,convits);
consol = round(convits/4); 
Hsol = zeros(N,consol);
cut1=0; cut2=0; cut3=0; 
cut = 40; cut5 = cut+10;
cut4 = ones(1,cut);
Svib = 0;
Hvib = 10;
Hcut = 5;
Hcheck = Hcut;
Hconverg = 0;
Hsupervise = 1;
Sprefer = pcut;
astep = pstep;
Kset = []; Kold = 0;
Sil = []; Silmax = 0;
Silstop = nrow;
Sildown = 0;
Kfixed = 0; Kfix = 0;


while ~dn
    i=i+1;

    % Compute responsibilities
    AS=A+S; 
    [Y,I]=max(AS,[],2); 
    for k=1:N 
        AS(k,I(k))= -realmax; 
    end;
    [Y2,I2]=max(AS,[],2); 
    AS = [];
    Rold=R;
    R=S-repmat(Y,[1,N]); 
    for k=1:N 
        R(k,I(k))=S(k,I(k))-Y2(k); 
    end;
    R=(1-lam)*R+lam*Rold; % Damping
    Rold = [];

    % Compute availabilities
    Rp=max(R,0);
    for k=1:N 
        Rp(k,k)=R(k,k);
    end; 
    Aold=A;
    A=repmat(sum(Rp,1),[N,1])-Rp; 
    Rp = [];
    dA=diag(A);
    A=min(A,0);
    for k=1:N 
        A(k,k)=dA(k);
    end;
    A=(1-lam)*A+lam*Aold; % Damping
    Aold = [];

    % Check for convergence
    E = ((diag(A)+diag(R))>0); 
    He(:,mod(i-1,convits)+1) = E;
    K=sum(E);
    Kset(i) = K;
    Hconv(:,mod(i-1,convinput)+1) = E;
    Hsol(:,mod(i-1,consol)+1) = E;
    
    if i>=convits || i>=maxits
        se = sum(He,2);
        se1 = sum(se==convits);
        se2 = sum(se==0); 
        unconverged = (se1+se2) ~= N;
        Hconverg = ~unconverged;
        se = sum(Hconv,2);
        se1 = sum(se==convinput);
        se2 = sum(se==0);
        if (se1+se2) == N || i == maxits
            dn=1;
        end
    end
    
    Hsave = 0;
 if sup   
    if i > 5
      cut1(i) = mean(Kset(i-5:i));
      cut2(i) = cut1(i)-cut1(i-1) < 0;
      cut3(i) = sum(abs(Kset(i)-Kset(i-5:i-1))); 
      cut4(:,mod(i-1,cut)+1) = cut2(i) || cut3(i) == 0;
      cut5 = sum(cut4);
    end
    
   if Hconverg
      Hcheck = Hcheck+1;
      if Hcheck > Hcut 
        Hsave = 1; 
        Hcheck = 0;
        if Sprefer < pmin
           astep = pstep;
           if K == Kfix
             Kfixed = Kfixed+1;
           else
             Kfixed = 0;
           end
           Kfix = K;
           if Kfixed > 2
              astep = 2*pstep;
           end
        end
      end
    end
 
    if (K <= 2 && Hsave) || Sildown >= Silstop
       dn = 1;
       unconverged = 0;
    end
    
    if Hsave || (Sildown && K >= Kold) 
      Svib = 0;
      if Hsupervise == 1 && Hsave
         Hsupervise = 2;                       % starting supervision
         labels = zeros(N,K);
         NC = zeros(1,K);
         convits = round(convits/2);
         He = He(:,1:convits);
      end
      Sprefer = Sprefer+astep;           % reducing pcut
      if length(pcut)==1
        for k=1:N
          S(k,k) = Sprefer;
        end
      else
        for k=1:N 
          S(k,k) = Sprefer(k);
        end;
      end;
      
    else
       Svib = Svib+1;
       if Svib > cut && cut5 < 0.66*cut 
          Hvib = Hvib+1;
          if Hvib > 10
            lam = 0.7;
          elseif Hvib >= 1
            lam = min([0.95 0.05+lam]);
          end
          Hvib = 0;
          Svib = 0;
       end
       
    end
 end
 
   if Hsave
      fprintf('** running at iteration %d\n', i);
   end
   if Hsupervise >= 2 && K < Kold && K > 1
      Hsave = 1; 
   end

    % Handle plotting and storage of details, if requested
    if plt || details || Hsave
        if K==0
            tmpnetsim=nan; tmpdpsim=nan; tmpexpref=nan; tmpidx=nan;
        else
            I=find(E); 
            [tmp c]=max(S(:,I),[],2); 
            c(I)=1:K;
            if Hsave || dn == 1
               labels(:,K) = c;
               NC(K) = K;
               tmp = silhouette(data, c, dtype);
               Silnew = mean(tmp);
               Sil(K) = Silnew;
               if Silnew >= Silmax
                 Silmax = Silnew;
                 Sildown = 0;
               elseif K < Kold && Silnew < Sil(Kold)
                 Sildown = Sildown+1;
               end
               Kold = K;
               if Hsupervise == 1
                  Silstop = fix(K/2)+1;
               end
               
            else
              tmpidx=I(c);
              tmpnetsim=sum(S((tmpidx-1)*N+[1:N]'));
              tmpexpref=sum(dS(I)); 
              tmpdpsim=tmpnetsim-tmpexpref;
            end
        end
    end;
    if details
        netsim(i)=tmpnetsim; dpsim(i)=tmpdpsim; expref(i)=tmpexpref;
        idx(:,i)=tmpidx;
    end;
    if plt
        netsim(i)=tmpnetsim;
        figure(234); 
        tmp=1:i; 
        tmpi=find(~isnan(netsim(1:i)));
        plot(tmp(tmpi),netsim(tmpi),'r-');
        xlabel('# Iterations');
        ylabel('Fitness (net similarity) of quantized intermediate solution');
        drawnow; 
    end;
end;


I=find(diag(A+R)>0); 
K=length(I); % Identify exemplars
if K>0
    [tmp c]=max(S(:,I),[],2); 
    c(I)=1:K; % Identify clusters
    % Refine the final set of exemplars and clusters and return results
    for k=1:K 
        ii=find(c==k); 
        [y j]=max(sum(S(ii,ii),1)); 
        I(k)=ii(j(1)); 
    end
    [tmp c]=max(S(:,I),[],2); 
    c(I)=1:K; 
    tmpidx=I(c);
    tmpnetsim=sum(S((tmpidx-1)*N+[1:N]')); 
    tmpexpref=sum(dS(I));
      labels(:,K) = c;
      NC(K) = K;
      tmp = silhouette(data, c, dtype);
      Sil(K) = mean(tmp);
else
    tmpidx=nan*ones(N,1); 
    tmpnetsim=nan; 
    tmpexpref=nan;
end;
if details
    netsim(i+1)=tmpnetsim; netsim=netsim(1:i+1);
    dpsim(i+1)=tmpnetsim-tmpexpref; dpsim=dpsim(1:i+1);
    expref(i+1)=tmpexpref; expref=expref(1:i+1);
    idx(:,i+1)=tmpidx; idx=idx(:,1:i+1);
else
    netsim=tmpnetsim; 
    dpsim=tmpnetsim-tmpexpref;
    expref=tmpexpref; 
    idx=tmpidx;
end;

NC(1) = 0;
S = find(NC);
NC = NC(S);
Sil = Sil(S);
labels = labels(:,S);
[Sil, Smax] = max(Sil);

Ha = [100 99 98];
if NC(Smax) == 2
  N = 3;
  for j = 1:N
    k = S(j);
    if strcmp(dtype,'euclidean')
       [ST,sw] = valid_sumsqures(data,labels(:,k),k);
    else
       [ST,sw] = valid_sumpearson(data,labels(:,k),k);
    end
    Ha (j) = trace(sw);
  end
  ST = trace(ST);
  Ha = [ST Ha];
  R = Ha(1:N)./Ha(2:N+1);
  Ha = (R-1).*(nrow-[S(1)-1 S(1:N-1)]-1); 
end

if Ha(1) < Ha(2) && Ha(1) <= 10
labels = ones(nrow,1);
NC = 1;
else
labels = labels(:,Smax);
NC = NC(Smax);
end

if unconverged
    fprintf('\n*** Warning: Algorithm did not converge. The similarities\n');
    fprintf('    may contain degeneracies - add noise to the similarities\n');
    fprintf('    to remove degeneracies. To monitor the net similarity,\n');
    fprintf('    activate plotting. Also, consider increasing maxits and\n');
    fprintf('    if necessary dampfact.\n\n');
end;
