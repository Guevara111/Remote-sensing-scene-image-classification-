sigma = [0.6 0; 0 0.6];
numData = 100;

mu = [6 5];
X_1 = mvnrnd(mu, sigma, numData);
label_1 = ones(numData, 1);

mu = [3 9];
X_2 = mvnrnd(mu, sigma, numData);
label_2 = 2*ones(numData, 1);

mu = [-2 7];
X_3 = mvnrnd(mu, sigma, numData);
label_3 = 3*ones(numData, 1);

data = [X_1; X_2; X_3];
label = [label_1; label_2; label_3];
%%
c =  optimizableVariable('c',  [1e-2 1e2], 'Type', 'real');
g =  optimizableVariable('g',  [2^-7 2^7], 'Type', 'real');
parameter = [c, g];

% 交叉验证参数设置（关闭交叉验证时设置为[]）
kfolds = 5;
% kfolds = [];

% 目标函数
%objFun = @(parameter) getObjValue(parameter, featuresTrain_juanji, label_train_ture, kfolds);
objFun = @(parameter) getObjValue(parameter, data, label, kfolds);
% 贝叶斯优化
iter = 30;
points = 10;
results = bayesopt(objFun, parameter, 'Verbose', 1, ...
                   'MaxObjectiveEvaluations', iter,...
                   'NumSeedPoints', points);
% 优化结果
[bestParam, ~, ~] = bestPoint(results, 'Criterion', 'min-observed');

%% 利用最优参数重新训练SVM模型
c = bestParam.c;  
g = bestParam.g; 

% 训练和测试
cmd = ['-s 0 -t 2 ', '-c ', num2str(c), ' -g ', num2str(g), ' -q'];
model = libsvmtrain(label, data, cmd);
[~, acc, ~] = libsvmpredict(label, data, model); 

%% SVM边界可视化
d = 0.02;
[X1, X2] = meshgrid(min(data(:, 1)):d:max(data(:, 1)), min(data(:, 2)):d:max(data(:, 2)));
X_grid = [X1(:), X2(:)];
grid_label = ones(size(X_grid, 1), 1);
[pre_label, ~, ~] = svmpredict(grid_label, X_grid, model);

% 绘制散点图
figure
color_p = [150, 138, 191;12, 112, 104; 220, 94, 75]/255; % 数据点颜色
color_b = [218, 216, 232; 179, 226, 219; 244, 195, 171]/255; % 边界区域颜色
hold on
ax(1:3) = gscatter(X_grid (:,1), X_grid (:,2), pre_label, color_b);

% 绘制原始数据图
ax(4:6) = gscatter(data(:,1), data(:,2), label);
set(ax(4), 'Marker','o', 'MarkerSize', 7, 'MarkerEdgeColor','k', 'MarkerFaceColor', color_p(1,:));
set(ax(5), 'Marker','o', 'MarkerSize', 7, 'MarkerEdgeColor','k', 'MarkerFaceColor', color_p(2,:));
set(ax(6), 'Marker','o', 'MarkerSize', 7, 'MarkerEdgeColor','k', 'MarkerFaceColor', color_p(3,:));
set(gca, 'linewidth', 1.1)
title('Decision boundary (gaussian kernel function)')
axis tight
legend('off')
box on
set(gca, 'linewidth', 1.1)

function objValue = getObjValue(parameter, data, label, kfolds)

    % cost 正则化系数
    c = parameter.c;
    % gamma 核参数
    g = parameter.g;

    switch ~isempty(kfolds)

        case 1
        cmd = ['-s 0 -t 2 ', '-c ', num2str(c), ' -g ', num2str(g),...
            ' -v ', num2str(kfolds), ' -q'];
        acc = svmtrain(label, data, cmd);

        case 0
        cmd = ['-s 0 -t 2 ', '-c ', num2str(c), ' -g ', num2str(g), ' -q'];
        model = svmtrain(label, data, cmd);
        [~, acc_, ~] = svmpredict(label, data, model);
        acc = acc_(1);
    end
    % 最小化错误率
    objValue = 1-acc/100;

end