
N1 = 10;
N2 = 10;
N = N1 + N2;
c = 0.3;
x1 = [c + rand(N1,1), c + randn(N1,1)];
x1 = [x1(:,1), log(x1(:,1)+1)+ 0.01*randn(N1,1)];
x2 = [-c + rand(N2,1), -c + randn(N2,1)];
x2 = [x2(:,1), log(x2(:,1)+1)+ 0.01*randn(N2,1)];
x = [x1;x2];
classes = [1*ones(N1,1);2*ones(N2,1)];

figure(1)
clf
subplot(2,1,1)
scatter(x(classes == 1,1),x(classes == 1,2),'b')
hold on
scatter(x(classes == 2,1),x(classes == 2,2),'r')
K = x*x';

params.max_class = 2; % maximum number of clusters
params.algo = 'kernel';  % may be 'kernel' or 'linear'
params.lambda = 1; % regularization parameter
model = RIM(K,[],[],params);

w = model.alphas*x;
figure(2)
scatter(w(:,1),w(:,2),30,'k','filled')

figure(3)
p = 1./(1+exp(-(model.alphas*K + repmat(model.bs,[1 N]))));
plot(p')
ylim([-0.1 1.1])

classes_o = 1*(p(1,:) > p(2,:)) + 2*(p(1,:) <= p(2,:));
classes_o = classes_o';
figure(1)
drawnow
subplot(2,1,2)
hold on
scatter(x(classes == 1 & classes_o == 1,1),x(classes == 1 & classes_o == 1,2),'b')
scatter(x(classes == 1 & classes_o == 2,1),x(classes == 1 & classes_o == 2,2),'b+')

scatter(x(classes == 2 & classes_o == 2,1),x(classes == 2 & classes_o == 2,2),'r')
scatter(x(classes == 2 & classes_o == 1,1),x(classes == 2 & classes_o == 1,2),'r+')

rend = 1-sum(abs(classes_o - classes))/N;
disp(rend)

% LDA
[C,err,P,logp,coeff] = classify(x,x,classes','linear');
rend_lda = 1-sum(abs(C - classes))/N;
disp(rend_lda)