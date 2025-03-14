% 作者：[马佳腾]
% 日期：[2025年03月]
% E-mail: jiateng.ma@qq.com

function [index_ss_yes,sf_basal] = ba_index(Sf)

% 无柱面 
index_ss_yes = 1;
sf_basal = abs(Sf(1)); % 直接输出最大的Sf

end
     