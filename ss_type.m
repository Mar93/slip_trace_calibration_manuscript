% 作者：[马佳腾]
% 日期：[2025年03月]
% E-mail: jiateng.ma@qq.com




function type_id = ss_type(index_ss_yes)
 if index_ss_yes == 1
     type_id = 1;
 elseif index_ss_yes == 0
     type_id = 0;
 elseif index_ss_yes > 1 &&  index_ss_yes < 5
     type_id = 2;
 elseif index_ss_yes > 4 &&  index_ss_yes < 11
     type_id = 3;
 elseif index_ss_yes > 10 &&  index_ss_yes < 23
     type_id = 4;
 else
     type_id = 5;
 end
end