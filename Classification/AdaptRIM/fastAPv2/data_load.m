function [data,truelabels,nrow] = data_load(sw,alabel,nrow,simatrix)

if simatrix == 1
    M = load(sw);
    if isstruct(M)
        M = M.s;       % given similarity matrix
    end
    data = M;
    if size(M,2) == 3
        nrow = max(max(M(:,1)),max(M(:,2)));
        data = zeros(nrow,nrow);
        n = size(M,1);
        for j = 1:n
            data(M(j,1),M(j,2)) = M(j,3);
        end
    end
else
    data = load(sw);
    if ~nrow
        [nrow, dim] = size(data);
    end
end

% taking true class labels from a data file
if alabel
   truelabels = data(:,1); 
   data = data(:,2:dim);
else
    truelabels = ones(nrow,1);
end
