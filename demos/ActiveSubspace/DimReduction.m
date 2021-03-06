clear all
rng(1)
ntrain = 150;
ntest = 10000;

%% Test function
d = 20; fcn = @welchetal92; lb = -0.5*ones(1, d); ub = 0.5*ones(1, d);

%% Training and test points
xtrain = rand(ntrain, d);
xtest = 0.1 + 0.8*rand(ntest, d);
[ytrain, dytrain] = feval(fcn, xtrain, lb, ub);
[ytest, dytest] = feval(fcn, xtest, lb, ub);


%% Remove the mean from the training data
ymean = mean(ytrain);
ytrain = ytrain - ymean;
ytest = ytest - ymean;


%% Dimensionality reduction
[Q, dvar] = dim_red(dytrain);
str = sprintf('%.3f%%, ', 100*dvar/sum(dvar));
str = ['[ ', str(1:end-2), ' ]'];
fprintf('Variance in each component: %s\n\n', str)

%% (1) Exact with gradients
n = ceil(ntrain/(d+1));
mu = gp_grad(xtrain(1:n,:), ytrain(1:n), dytrain(1:n,:));
ypred_exact_grad = mu(xtest);

%% (2) SKI with gradients, using an active subspace of dimension 2
dtilde = 2;
QQ = Q(:, 1:dtilde);
xQ = xtrain * QQ;
dfxQ = dytrain * QQ;
xQtest = xtest * QQ;

mu = gp_SKI_grad(xQ,ytrain, dfxQ);
ypred_ski_grad = mu(xQtest);

%% (3) SKIP with gradients, using an active subspace of dimension 6
dtilde = 6;
QQ = Q(:, 1:dtilde);
xQ = xtrain * QQ;
dfxQ = dytrain * QQ;
xQtest = xtest * QQ;

mu = gp_SKIP_grad(xQ,ytrain, dfxQ);
ypred_skip_grad = mu(xQtest);

%% RMSE prediction errors
fprintf('\n=== Relative RMSE prediction errors ===\n')
fprintf('Exact with gradients: %.3e\n', ...
    norm(ypred_exact_grad - ytest)/norm(ytest))
fprintf('SKI with gradients: %.3e\n', ...
    norm(ypred_ski_grad - ytest)/norm(ytest))
fprintf('SKIP with gradients: %.3e\n', ...
    norm(ypred_skip_grad - ytest)/norm(ytest))

fprintf('\n=== SMAE prediction errors ===\n')
fprintf('Exact with gradients: %.3e\n', ...
    sum(abs(ypred_exact_grad - ytest))/sum(abs(ytest)))
fprintf('SKI with gradients: %.3e\n', ...
    sum(abs(ypred_ski_grad - ytest))/sum(abs(ytest)))
fprintf('SKIP with gradients: %.3e\n', ...
    sum(abs(ypred_skip_grad - ytest))/sum(abs(ytest)))

%% Plot in four separate plots

nplot = 4000;
xplot = rand(nplot, d);
[yplot, dyplot] = feval(fcn, xplot, lb, ub);
ymean = mean(yplot);
yplot = yplot - ymean;
ytest = ytest - ymean;
[Q, dvar] = dim_red(dyplot);
str = sprintf('%.3f%%, ', 100*dvar/sum(dvar));
str = ['[ ', str(1:end-2), ' ]'];
fprintf('Variance in each component: %s\n\n', str)
dtilde = 2;
QQ = Q(:, 1:dtilde);
xQ = xplot * QQ;
dfxQ = dyplot * QQ;
xQtest = xtest * QQ;

subplot(2,2,1);
semilogy(dvar(1:10),'.','MarkerSize',40)
hold on
semilogy(dvar(1:10),'LineWidth',4)
set(gca,'FontSize',20,'xtick',1:10,'xticklabel',1:10,'ytick',[1e-15 1e-10 1e-5 1e0],'yticklabel',[-15,-10,-5,0]);
xlim([0 10]); ylim([1e-17 1000]);

subplot(2,2,2);
scatter(xQ(:,1),yplot,20,yplot,'filled')
colormap jet
box on
set(gca,'FontSize',20)

subplot(2,2,3);
scatter(xQ(:,2),yplot,20,yplot,'filled')
colormap jet
box on
set(gca,'FontSize',20)

subplot(2,2,4);
scatter(xQ(:,1),xQ(:,2),20,yplot,'filled')
colormap jet
box on
set(gca,'FontSize',20)