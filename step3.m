%% 滑移迹线统计分析与可视化
% 本代码用于统计分析EBSD滑移迹线识别的结果，并生成可视化图表
% 包括滑移系分布饼图和施密特因子统计图表
% 作者：[马佳腾]
% 日期：[2025年03月]


% 清除变量和关闭所有图窗
clear;
clc;
%close all

% 加载先前保存的滑移迹线分析结果
load('ten2_Ti_part_slip_trace_new.mat');  

%% 基本统计数据准备
ngrain_all = 120;  % 总共晶粒个数
n_with_trace = sum(output2(:,1) ~= 0);  % SEM中有滑移迹线的晶粒个数
 
% 提取滑移系类型和施密特因子数据
ss_type = output2(1:n_with_trace, 2);
SFs = abs(output2(1:n_with_trace, 4));

% 排除无效数据
SFs = SFs(SFs ~= 0);
ss_type = ss_type(ss_type ~= 0);

% 计算统计指标
n_indexed_ss = length(ss_type);  % 确定了滑移系类型的晶粒个数
n_not_sure_ss = (n_with_trace - n_indexed_ss);  % 有迹线但未能确定滑移系的晶粒
n_no_trace = (ngrain_all - n_with_trace);  % 无可见滑移迹线的晶粒

%% 图1：晶粒滑移迹线状态分布饼图
pie_data = [n_no_trace; n_not_sure_ss; n_indexed_ss];
labels = {'No slip trace', 'Not indexed sS', 'Indexed sS'};

figure(1)
explode = [0 0 1];  % 突出显示第三部分
h = pie(pie_data, explode, '%.1f%%');

% 设置标签的字体格式
for i = 2:2:length(h)
    h(i).FontName = 'Times New Roman';
    h(i).FontSize = 18;
end

% 设置饼图各部分的样式
alphas = [0.9, 0.3, 0.3];  % 透明度
for i = 1:2:length(h)
    % 设置颜色和透明度
    h(i).FaceColor = my_c(10-(i+1)/2);
    h(i).FaceAlpha = alphas((i+1)/2);
    
    % 设置边界样式
    h(i).EdgeColor = 'k';
    h(i).EdgeAlpha = 1;
    h(i).LineWidth = 2;
end

%% 图2：已识别滑移系类型分布饼图
% 计算各类滑移系的数量及占比
[unique_elements, ~, idx] = unique(ss_type);
element_counts = accumarray(idx, 1);
percentages = (element_counts / numel(ss_type)) * 100;

labels2 = {'B', 'Pr', 'Py-a', 'Py-ca', 'Py-2ca'};

figure(2)
explode = [1 1 1 1 1];  // 所有部分均突出显示
h2 = pie(percentages, '%.1f%%');

% 设置标签的字体格式
for i = 2:2:length(h2)
    h2(i).FontName = 'Times New Roman';
    h2(i).FontSize = 18;
end

% 设置饼图各部分的样式
for i = 1:2:length(h2)
    h2(i).FaceColor = my_c((i+1)/2);
    h2(i).FaceAlpha = 0.8;
    h2(i).EdgeColor = 'k';
    h2(i).EdgeAlpha = 1;
    h2(i).LineWidth = 2;
end

%% 图3：施密特因子分布堆叠条形图
% 初始化数据矩阵
sf_for_act_ss = zeros(5, 5);
% 五行分别是施密特因子的5个分段
% 五列分别是5种滑移系类型

% 定义施密特因子分段边界
edges = 0:0.1:0.5;

% 使用histcounts计算每个分段的元素个数
[counts, edges] = histcounts(SFs, edges);

% 使用discretize获取每个元素对应的分段索引
indx = discretize(SFs, edges);

% 统计每种滑移系在各施密特因子区间的分布
for i = 1:length(SFs)
    sf_scale = indx(i);  % 施密特因子范围索引(1-5)
    ss_type_c = ss_type(i);  % 滑移系类型
    sf_for_act_ss(sf_scale, ss_type_c) = sf_for_act_ss(sf_scale, ss_type_c) + 1;
end

% 计算百分比
sf_for_act_ss = sf_for_act_ss ./ length(SFs) * 100;

% 绘制堆叠条形图
figure(3)
barHandle = bar(sf_for_act_ss, 'stacked', 'BarWidth', 0.4);

% 设置条形图样式
for i = 1:length(barHandle)
    barHandle(i).FaceAlpha = 0.8;
    barHandle(i).LineWidth = 1.5;
end

% 为每个条形分段设置颜色
for i = 1:size(sf_for_act_ss, 2)
    for j = 1:size(sf_for_act_ss, 1)
        barHandle(i).FaceColor = 'flat';
        barHandle(i).CData(j, :) = my_c(i);
    end
end

% 设置图表格式
set(gca, 'FontSize', 20, 'fontname', 'Times New Roman', 'LineWidth', 2);
xlabel('Schmid factor', 'FontSize', 32, 'fontname', 'Times New Roman')
ylabel('Fraction of activated sS (%)', 'FontSize', 32, 'fontname', 'Times New Roman') 
xlim([0.5 5.5]);
ylim([0 80]);
legend('B', 'Pr', 'Py-a', 'Py-ca', 'Py-ca2', 'Location', 'best', 'NumColumns', 2)
text(0.01, 0.94, '(b)', 'FontSize', 40, 'Color', 'k', 'fontname', 'Times New Roman', 'Units', 'normalized');
xticklabels({'0-0.1', '0.1-0.2', '0.2-0.3', '0.3-0.4', '0.4-0.5'});

%% 保存高分辨率图像
% 以600 DPI的分辨率保存图像为TIFF格式
print(figure(3), '-dtiff', '-r600', 'save_path/aa');
print(figure(2), '-dtiff', '-r600', 'save_path/bb');
print(figure(1), '-dtiff', '-r600', 'save_path/cc');
