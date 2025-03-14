% 作者：[马佳腾]
% 日期：[2025年03月]
% E-mail: jiateng.ma@qq.com

function index_ss_yes = pr_index(ind_SSs,Sf)

% 输入符合的序号



% 计算符合的个数
n_pr =  sum(ismember(ind_SSs,2)) +sum( ismember(ind_SSs,3)) + sum(ismember(ind_SSs,4));
if n_pr > 1 
    % 多个符合的,取施密特因子最小的那个
    index_ss_posibel = intersect(ind_SSs,[2,3,4]);
    SF_posibel = abs(Sf(index_ss_posibel));
    [~,indx] = max(SF_posibel);
    index_ss_yes = index_ss_posibel(indx);
    
    
else
    %只有一个
    index_ss_yes = intersect(ind_SSs,[2,3,4]);
end
     