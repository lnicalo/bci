function out = dispmat(M,row_labels,col_labels);
%% Matthew Oberhardt
% 02/08/2013
% intended to display a matrix along with row and column labels.
% % ex:
% M = rand(2,3);
% row_labels = {'a';'b'};
% col_labels = {'c 1','c2 ','c3'};
% % if there are no labels for rows or cols, put '' as the input.
% row_labels = '';

%% check that the row & col labels are the right sizes
[nrows,ncols] = size(M);

%% populate if either of the inputs is empty 
if isempty(row_labels)
    row_labels = cell(1,nrows);
    for n = 1:nrows
        row_labels{1,n} = '|'; 
    end
end
if isempty(col_labels)
    col_labels = cell(1,ncols);
    for n = 1:ncols
        col_labels{1,n} = '-';
    end
end

assert(length(row_labels)==nrows,'wrong # of row labels');
assert(length(col_labels)==ncols,'wrong # of col labels');

row_labels = reshape(row_labels,1,length(row_labels));
col_labels = reshape(col_labels,1,length(col_labels));

%% remove spaces (since they are separators in printmat.m
cols = strrep(col_labels, ' ', '_');
rows = strrep(row_labels, ' ', '_');

%% create labels, space delimited
c_out = [];
for n = 1:length(cols)
    c_out = [c_out,cols{n},' '];
end
c_out = c_out(1:end-1);

r_out = [];
for n = 1:length(rows)
    r_out = [r_out,rows{n},' '];
end
r_out = r_out(1:end-1);

%% print
printmat(M, '',r_out,c_out)