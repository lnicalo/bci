function R=cormat(X,Y)
%USAGE  R=cormat(X,Y)
% from X (I*J) and Y (I*K)
% compute an J*K correlation matrix
% corresponding to the correlation
% between the J columns of X
%         and K columns of Y
%
[ix,jx]=size(X);
[iy,jy]=size(Y);
C=corrcoef([X,Y]);
R=C(1:jx,jx+1:jx+jy);
