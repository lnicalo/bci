function plotxy(F,axe1,axe2,titre,noms);
% % ***** This is a Test  Version *******
% July 1998 Herve Abdi
% Usage plotxy(F,axe1,axe2,title,names);
% plotxy plots a MDS or PCA or CA graph of component #'Axe1' vs #'Axe2'
% F is a matrix of coordinates
% axe1 is the Horizontal Axis
% axe2 is the Vertical Axis
% title will be the title of the graph
% Axes are labelled 'Principal Component number'
% names give the names of the points to plot (def=numbers)

nom_de_dim='Dimension';
[nrow,ncol]=size(F);
if exist('noms')==0;
   noms{nrow,1}=[];
   for k=1:nrow;noms{k,1}=int2str(k);end
end   
 minx=min(F(:,axe1));
 maxx=max(F(:,axe1));
 miny=min(F(:,axe2));
 maxy=max(F(:,axe2));
 hold off; clf;hold on;
 rangex=maxx-minx;epx=rangex/10;
 rangey=maxy-miny;epy=rangey/10; axis('equal');
 axis([minx-epx,maxx+epx,miny-epy,maxy+epy]) ;
 %axis('equal');
%axis;
plot ( F(:,axe1),F(:,axe2 ),'.');
label=[nom_de_dim,': '];
labelx=[label, num2str(axe1) ];
labely=[label, num2str(axe2) ];
xlabel (labelx);
ylabel (labely );
plot([minx-epx,maxx+epx],[0,0] ,'b');
% hold
plot ([0,0],[miny-epy,maxy+epy],'b');
for i=1:nrow,
  text(F(i,axe1),F(i,axe2),noms{i,1});
end;
title(titre);

