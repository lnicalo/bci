function [R, dmax]= similarity_euclid(data,varargin)
% input: data --- observations x dimensions
% output: R --- pairwise Euclidean distances between observations

nrow = size(data,1);
nend = nrow-1;
data = data';
dmax = 0;
ch = 1;
if nargin > 1
    ch = varargin{1};
    if strcmp(nend, 'square')
        ch = 0;
    elseif ch > 0
        nend = ch;
        R = zeros(nend,nrow);
    end
else
    R = zeros(nrow,nrow);
end

if ch
% distance between two observations
for i = 1:nend
 x = data(:,i);
 for j = (i+1):nrow
   y = x-data(:,j);
   d = y'*y;
   d = sqrt(d);
   R(i,j) = d;
%    R(j,i) = d; 
   if d > dmax 
       dmax = d; 
   end
 end
end

else
% square distance between two observations
for i = 1:nend
 x = data(:,i);
 for j = (i+1):nrow
   y = x-data(:,j);
   d = y'*y;
   R(i,j) = d;
%    R(j,i) = d;
   if d > dmax 
       dmax=d; 
   end
 end
end

end

if size(R,1) == size(R,2)
    R = R+R';
end