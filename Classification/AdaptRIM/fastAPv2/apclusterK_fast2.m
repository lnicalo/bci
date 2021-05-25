function [idx,netsim,dpsim,expref,pref,lowp,highp]=apclusterK_fast2(...
          S,kk,prc,nrun,nconv,lam,splot,lowp,highp,highk)
% Finds approximately k clusters using affinity propagation (BJ Frey and
% D Dueck, Science 2007), by searching for an appropriate preference value
% using a bisection method. By default, the method stops refining the
% number of clusters when it is within 10%% of the value k provided by the
% user. To change this percentage, use apclusterK(s,k,prc) -- eg, setting
% prc to 0 causes the method to search for exactly k clusters. In any case
% the method terminates after 20 bisections are attempted.

N=size(S,1);
if kk == 1
    % Find limits
    [dpsim1 tmp]=max(sum(S,1));
    if dpsim1==-Inf
        error('Could not find pmin');
    elseif N>1000
        for k=1:N S(k,k)=-Inf; end;
        m=max(S,[],2);
        tmp=sum(m);
        [yy ii]=min(m);
        tmp=tmp-yy-min(m([1:ii(1)-1,ii(1)+1:N]));
        pmin=dpsim1-tmp;
    else
        dpsim2=-Inf;
        for j21=1:N-1
            for j22=j21+1:N
                tmp=sum(max(S(:,[j21,j22]),[],2));
                if tmp>dpsim2 dpsim2=tmp; k21=j21; k22=j22; end;
            end
        end
        pmin=dpsim1-dpsim2;
    end
    lowp = pmin;
    for k=1:N S(k,k)=-Inf; end;
    highp = max(S(:));
    pref = []; idx=[]; netsim=[]; dpsim=[]; expref=[];
    return

else
    lowk = 1;
    highpref = highp;
    lowpref = lowp;
    fprintf('Bounds: lowp=%f  highp=%f  lowk=%d  highk=%d\n',...
        lowpref,highpref,lowk,highk);
    fprintf('Attempting to improve lower bound:\n');

    % Run AP several times to find better lower bound
    dt = highp;
    if ~highp
        dt = -realmin;
    end
    p2 = abs(1-(1-lowp/dt)/100);
    p3 = abs(1-(1-lowp/dt)/1000);
    p4 = abs(1-(1-lowp/dt)/10000);
    if kk < 11
        B = -1;
    elseif kk < 31
        B = [-2 -1];
        if p2 < 10
            B = -1;
        end
    elseif  kk < 101
        B = [-3 -2 -1];
        if p2 < 10
            B = -1;
        elseif p3 < 10
            B = [-2 -1];
        end
    else
        B = [-4 -3 -2 -1];
        if p2 < 10
            B = -1;
        elseif p3 < 10
            B = [-2 -1];
        elseif p4 < 10
            B = [-3 -2 -1];
        end
    end
    
    % add a tiny amount of noise
    rns=randn('state'); randn('state',0);
    S=S+(eps*S+realmin*100).*rand(N,N);
    randn('state',rns);

    for i = B
        tmppref = highp-10^i*(highp-lowp);
        fprintf('  Trying p= %f',tmppref);
        [idx,netsim,dpsim,expref] = apcluster(S,tmppref,'sparse',...
            'dampfact',lam,'convits',nconv,'maxits',nrun,'nonoise');
        tmpk = length(unique(idx));
        fprintf('  Found k = %d\n',tmpk);
        if tmpk <= kk  % if better lower bound is found
            lowk = tmpk;
            lowpref = tmppref;
            break
        else           % upper bound is found
            highk = tmpk;
            highpref = tmppref;
        end        
    end
end

if nargin<3 prc=10; end; % Default percentage error in k

% Use bisection method to find k
if abs(tmpk-kk)/kk*100>prc
    fprintf('== Start with lowp=%f  highp=%f  lowk=%d  highk=%d\n', ...
        lowpref,highpref,lowk,highk);
    fprintf('Applying heuristic search and bisection method:\n');
    ntries=0;
    B = -1;
    while (abs(tmpk-kk)/kk*100 > prc) && (ntries<20)
        tmppref = 0.5*(highpref+lowpref);
        kpart = (kk-lowk)/(highk-lowk);
        if B == -1 || highk-lowk < 6
        elseif kpart < 0.1
            tmppref = 0.618*lowpref+0.382*highpref;
        end
        [idx,netsim,dpsim,expref]=apcluster(S,tmppref,'sparse', ...
            'dampfact',lam, 'convits',nconv,'maxits',nrun,'nonoise');
        tmpk=length(unique(idx));
        if kk>tmpk lowpref=tmppref; lowk=tmpk;
        else highpref=tmppref; highk=tmpk;
        end;
        fprintf('  lowp=%f  highp=%f   lowk=%d  highk=%d\n', ...
            lowpref,highpref,lowk,highk);
        ntries=ntries+1;
        B = -B;
    end
end
pref=tmppref;
fprintf('Found %d clusters using a preference of %f\n',tmpk,pref);
