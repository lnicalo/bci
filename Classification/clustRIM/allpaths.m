function [paths] = allpaths(wt, startnode, endnode)
lastpath = [startnode]; %We begin with the path containing just the startnode
costs = [0]; %The cost of this path is zero because we haven't yet crossed any edges
paths = {zeros(0,1),zeros(0,1)}; %The set of solution paths is empty (I'm assuming startnode!=endnode)
N = size(wt,1); %Obtain the number of nodes in the graph
assert(N==size(wt,2)); %Assert that the adjacency matrix is a square matrix
for i = 2 : N
    %Creates a matrix with a row for each path and a 1 in a column where there's a possible move from the last visited node in a path to this column
    nextmove = wt(lastpath(:, i - 1), :) ~= 0;
    % Zero out any nodes we've already visited
    d = diag(1:size(lastpath,1));
    nrows = d * ones(size(lastpath));
    inds = sub2ind(size(nextmove), reshape(nrows,[],1), reshape(lastpath,[],1));
    nextmove(inds) = false;

    % If there are no more available moves we're done
    if nextmove == 0
        break;
    end%if

    % For each true entry in our nextmove matrix, create a new path from the old one together with the selected next move
    nextmoverow = d * nextmove;
    nextmovecol = nextmove * diag(1:N);
    rowlist = reshape(nonzeros(nextmoverow),[],1);
    collist = reshape(nonzeros(nextmovecol),[],1);
    nextpath = [lastpath(rowlist,:), collist];

    % Compute the costs of the new set of paths by adding the old ones to the cost of each newly traversed edge
    inds = sub2ind([N,N],nextpath(:, i-1),nextpath(:,i));
    costs = costs(rowlist) + wt(inds);
    if costs==4
        break;
    end
    %condition for cost
    % For any path finishing on the end node, add it to the return list (and it's corresponding cost)
    reachedend = nextpath(:,i) == endnode;
    paths = [paths; {nextpath(reachedend, :)},{costs(reachedend)}];
    % make reachedend with such condition zero
    %Then remove it from the list of paths still being explored
    lastpath = nextpath(~reachedend, :);
    costs = costs(~reachedend);

    % If there are no more paths, we're done
    if isempty(lastpath)
        break;
    end%if
end%for
end%function