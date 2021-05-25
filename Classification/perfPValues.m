%% Methods
methods = [
    
    0.466 0.796 0.354 0.657 0.111 0.086 0.412 0.883 0.064 0.000 0.480 0.615 0.078 0.490;
    0.603 0.907 0.383 0.891 0.103 0.229 0.299 0.941 0.140 0.048 0.354 0.757 0.080 0.506;
    0.587 0.779 0.337 0.623 0.085 0.096 0.430 0.874 0.092 0.055 0.506 0.673 0.077 0.598;
    0.781 0.890 0.442 0.891 0.042 0.271 0.342 0.941 0.139 0.080 0.338 0.816 0.146 0.598
];

%% Competitors
competitors = [methods

];

% competitors = methods;

N = size(competitors,1);
M = size(methods,1);
alpha = 0.05;
fprintf('\n');
fprintf('ttest\n');
pvalues = NaN(N,M);
for i = 1:N
    for j = 1:M
        [y,pvalues(i,j)] = ttest(competitors(i,:),methods(j,:),alpha);
    end
end
printmat(pvalues)
fprintf('\n')

fprintf('Sign test\n');
pvalues = NaN(N,M);
for i = 1:N
    for j = 1:M
        [pvalues(i,j),y] = signtest(methods(i,:),competitors(j,:), 'tail', 'right', 'alpha', 0.05);
    end
end
printmat(pvalues)
fprintf('\n')

fprintf('Sign rank\n');
pvalues = NaN(N,M);
for i = 1:N
    for j = 1:M
        [pvalues(i,j),y] = signrank(methods(i,:),competitors(j,:), 'tail', 'right', 'alpha', 0.05);
    end
end
printmat(pvalues)
fprintf('\n')




