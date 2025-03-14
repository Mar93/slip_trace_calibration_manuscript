%% 图像分析与滑移迹线索引
% 本部分代码用于导入SEM图像，进行滑移迹线分析和索引
% 将EBSD数据与SEM图像对齐，进行晶体学分析
% 作者：[马佳腾]
% 日期：[2025年03月]

%% 设置图像与初始化
figure(2)

%% 输出矩阵说明
% 输出一个矩阵，包含以下信息：
% 第一列: 晶粒id
% 第二列: 滑移类型
%  0: 有滑移迹线但类型为其他
%  1: 基面滑移(basal)
%  2: 柱面a滑移
%  3: 锥面C+A滑移
% 第三列: 备注，如果无可见滑移迹线，备注为1

%% 导入SEM图像
% 指定图像路径 拼接好的SEM图像
imagePath = 'SEM_image_path.tif'; 

% 导入并显示图像
img = imread(imagePath);
imshow(img);
title('SEM Image');
hold on

%% EBSD与SEM图像对齐
% 第一次运行使用ebsd2sem函数统一ebsd和sem图像位置和大小
ebsd2sem

% 后续运行可直接使用下面的对齐点坐标
p1_sem = [x(1), y(1)];     % SEM图像上的参考点1
p2_sem = [x(2), y(2)];   % SEM图像上的参考点2

%% 设置数据保存文件名
save_file_mat_name = 'ten2_individual_analize_part_slip_trace';

%% 执行滑移迹线索引
% ========================================
trace_indexing   % 执行滑移迹线索引分析,主程序
% ========================================
%% 辅助函数：EBSD与SEM图像对齐
function ebsd2sem
    % 通过用户交互获取EBSD数据在SEM图像上的对应点
    [x, y] = ginput(2);  % 这两个点分别为SEM图像中EBSD数据的左上角和右下角所在的点

    % 显示点击的点
    hold on;
    plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    hold off;

    % 输出坐标信息用于后续分析
    fprintf('First point: (%.2f, %.2f)\n', x(1), y(1));
    fprintf('Second point: (%.2f, %.2f)\n', x(2), y(2));
end