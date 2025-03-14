%% 初始化EBSD数据
% 本代码用于导入EBSD数据和初始化
% 作者：[马佳腾]
% 日期：[2025年03月]

%% 数据初始化与预处理
clear; % 清除所有变量
clc; % 清除命令窗口内容


%% 注意事项
%**********************开始之前确保路径之下有以下文件*************************************
% load('data_output.mat', 'output'); 
%*************************************************************************************

%% 导入EBSD数据
% 此脚本由导入向导自动创建，用于导入EBSD数据
CS = {... 
  'notIndexed',...
  crystalSymmetry('6/mmm', [3.2 3.2 5.1], 'X||a*', 'Y||b', 'Z||c*', 'mineral', 'Zirc-alloy4', 'color', [0.53 0.81 0.98])};

% 设置绘图约定
setMTEXpref('xAxisDirection','east');
setMTEXpref('zAxisDirection','intoPlane');

%% 指定文件名和路径

% 文件路径
pname = '/xxxx'; % .cpr文件所在路径

% 导入的文件
fname = [pname '/specimen.cpr']; %"specimen"改为文件名

%% 导入数据
% 创建包含数据的EBSD变量
ebsd = EBSD.load(fname, CS, 'interface', 'crc',...
  'convertEuler2SpatialReferenceFrame');

%% 绘制反极图(IPF)
figure(1)

% 设置IPF颜色键
ipfKey = ipfColorKey(ebsd('Zirc-alloy4'));
ipfKey.inversePoleFigureDirection = vector3d.Y;
colors = ipfKey.orientation2color(ebsd('Zirc-alloy4').orientations);

% 绘制IPF图
plot(ebsd('Zirc-alloy4'), colors, 'micronbar', 'on'); % 包含微米标尺
hold on

%% 晶粒重构与优化

% 计算晶粒
[grains, ebsd.grainId, ebsd.mis2mean] = calcGrains(ebsd('indexed'), 'angle', 10*degree);

% 移除过小的晶粒
ebsd(grains(grains.grainSize < 5)) = [];

% 重新进行晶粒分割
[grains, ebsd.grainId] = calcGrains(ebsd, 'angle', 10*degree);

% 平滑晶界
grains = smooth(grains, 5);

hold on

% 绘制晶界
plot(grains.boundary, 'linecolor', 'k', 'linewidth', 1.5)
hold on

%% 加载历史数据，用作断点连续
  
load('data_output.mat', 'output');   % 此处“data_output.mat”与step0中为同一文件
ind_all = output(:,1);
grain_is_yes = ind_all(ind_all ~= 0);

% 突出显示特定晶粒边界和晶粒
plot(grains(grain_is_yes).boundary, 'lineWidth', 4, 'lineColor', 'gold')
hold on
plot(grains(grain_is_yes)) %将已经鉴别过的晶粒标记