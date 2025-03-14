% 作者：[马佳腾]
% 日期：[2025年03月]
% E-mail: jiateng.ma@qq.com


function [index_ss_yes,sf_act_ss] = py_index(ind_SSs,Sf)

% 用于区别仅有符合锥面 10-11 面的情况



% 计算符合的个数
py_plane_posible =  intersect(ind_SSs,[5,6,7,8,9,10,11,12,13,14,15,16]);

py_list = [1,9,10;...
    2,7,8;...
    3,11,12;...
    4,13,14;...
    5,15,16;...
    6,17,18;...
    19,19,19;...
    20,20,20;...
    21,21,21;...
    22,22,22;...
    23,23,23;...
    24,24,24];

py_posible = py_list(py_plane_posible-4,:);
py_posible = unique(py_posible( : ));

sf_posible = abs(Sf(py_posible));
[sf_max,indx] = max(sf_posible);


index_ss_yes = py_posible(indx);
sf_act_ss = sf_max;


end
