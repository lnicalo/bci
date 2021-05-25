function R = similarity_pearson(data,varargin)
% pearson coefficients between columns

[nrow,ncol] = size(data);
x = mean(data);
data = data-repmat(x,nrow,1);
if nargin > 1
    nend = varargin{1};
    R = ones(nend,ncol);
else
    nend = ncol-1;
    R = ones(ncol,ncol);
end

if size(R,1) == size(R,2)
    for i = 1:nend
        x = data(:,i);
        X = sqrt(x'*x);
        for j = (i+1):ncol
            y = data(:,j);
            xy = x'*y;
            Y = sqrt(y'*y);
            XY = X*Y;
            if XY > 0
                sim = xy/(XY);
                R(i,j) = sim;
                R(j,i) = sim;
            else
                R(i,j) = -1;
                R(j,i) = -1;
            end
        end
    end

else
    for i = 1:nend
        x = data(:,i);
        X = sqrt(x'*x);
        for j = (i+1):ncol
            y = data(:,j);
            xy = x'*y;
            Y = sqrt(y'*y);
            XY = X*Y;
            if XY > 0
                sim = xy/(XY);
                R(i,j) = sim;
                %R(j,i) = sim;
            else
                R(i,j) = -1;
            end
        end
    end
end