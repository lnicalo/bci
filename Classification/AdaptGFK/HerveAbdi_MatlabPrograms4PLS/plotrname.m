function plotrname(F,axe1,axe2,titre,noms);
% % ***** This is a Test  Version *******
% June  1998 Herve Abdi
% Usage plotr(R,axe1,axe2,title,nom_j);
% plotr plots the correlations with
%       of the original variable with the PC
% F is a matrix of coordinates
% axe1 is the Horizontal Axis
% axe2 is the Vertical Axis
% title will be the title of the graph
% nom_j (optional) name of the variables
% Axes are labelled 'Principal Component number'
% See also plotr (same program but without variable names


[nrow,ncol]=size(F);
if exist('noms')==0;
   noms{nrow,1}=[];
   for k=1:nrow;noms{k,1}=int2str(k);end
end  
minx=-1;maxx=+1;
miny=-1;maxy=+1;
 hold off; clf;hold on;
 rangex=maxx-minx;epx=rangex/10;
 rangey=maxy-miny;epy=rangey/10;
 axis([minx-epx,maxx+epx,miny-epy,maxy+epy]) ;
 %axis('equal');% 
axis('square')
%axis;
plot ( F(:,axe1),F(:,axe2 ),'.');
label=' Correlation with Principal Component # ';
labelx=[label, num2str(axe1) ];
labely=[label, num2str(axe2) ];
xlabel (labelx);
ylabel (labely);
plot([minx-epx,maxx+epx],[0,0] ,'b');
% hold
plot ([0,0],[miny-epy,maxy+epy],'b');
% Print the names
for i=1:nrow,
  text(F(i,axe1),F(i,axe2),noms{i,1});
end;
 
title(titre);
x=-1:.01:1;
y2=1-x.^2;
y=y2.^(1/2);
X=[x,x;y,-y];
X=[x,x;y,-y];
nrx=max(size(X));
rowx=max(size(x));
plot(X(1,1:rowx),X(2,1:rowx),'-r',...
  X(1,rowx+1:nrx),X(2,rowx+1:nrx),'-r');axis('square')

