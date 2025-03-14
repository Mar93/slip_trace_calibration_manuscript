
%% 滑移迹线识别与索引算法（trace_indexing_v3函数）
% 本函数用于分析SEM图像中的滑移迹线，并基于晶体学原理进行索引
% 修改历史：
% - 修改了滑移迹线的判定逻辑，对比SEM trace与晶面投影的夹角
% - 比较满足条件的滑移系对应的SF进行CRSS加权
% - 参考文献: Acta Materialia 61 (2013) 7555-7567 for Ti
% - 2024-07-21: 重写了基线归属逻辑
% 作者：[马佳腾]
% 日期：[2025年03月]
% E-mail: jiateng.ma@qq.com

function trace_indexing_v3
    % 定义应力张量
    sigma = stressTensor(diag([1,0,0]));
    
    % 两个标记点在EBSD图像中的坐标
    p1_ebsd = [0,0];
    p2_ebsd = [max(ebsd.prop.x),max(ebsd.prop.y)];
    
    % 计算SEM与EBSD图像的比例尺
    scale = (p2_sem(1)-p1_sem(1))/max(ebsd.prop.x);
    
    % 创建图3，设置高分辨率和固定窗口大小
    figure(3);
    set(gcf, 'Units', 'pixels', 'Position', [600, 600, 2000, 2000]);
    set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0, 0, 8, 8]);
    
    %% 预定义滑移系

    % 定义各类滑移系
    sSBasal = slipSystem.basal(CS{2}, 1);
    sSBasal_all = sSBasal.symmetrise('antipodal');
    
    sSPrismatic = slipSystem.prismatic2A(CS{2}, 1);
    sSPrismatic = sSPrismatic.symmetrise('antipodal');
    
    % 锥面a滑移系
    sSPyramidala = slipSystem.pyramidalA(CS{2}, 1);
    sSPyramidala = sSPyramidala.symmetrise('antipodal');
    
    % 锥面c+a (I型)滑移系
    sSPyramidalca = slipSystem.pyramidalCA(CS{2}, 1);
    sSPyramidalca = sSPyramidalca.symmetrise('antipodal');
    
    % 锥面c+a (II型)滑移系 - 6种际线，6个滑移系
    sSPyramidal2ca = slipSystem.pyramidal2CA(CS{2}, 1);
    sSPyramidal2ca = sSPyramidal2ca.symmetrise('antipodal');
    
    %% 初始化迭代计数
    n_gra = sum(output(:,1) ~= 0);
    
    %% 主循环：交互式选择晶粒并分析
    while true
        n_gra = n_gra + 1;
        indSelected = [];
        
        % 激活EBSD图像并将其置顶
        figure(1);
        legend off
        selectInteractive(grains, 'lineColor', 'gold')
        
        waitforbuttonpress; % 等待按钮被按下
        
        % 检查是否是鼠标左键点击
        clickType = get(gcf, 'SelectionType');
        if strcmp(clickType, 'normal')  % 'normal'表示左键点击
            global indSelected;
            the_grain = grains(indSelected);
            sele_indx = indSelected(end);
            
            % 高亮显示选中晶粒
            hold on
            plot(grains(sele_indx).boundary, 'lineWidth', 4, 'lineColor', 'gold')
            hold on
            plot(the_grain)
            hold on
            
            %% 获取当前晶粒信息
            output(n_gra, 1) = the_grain.id;  % 晶粒ID
            center_xy = the_grain.centroid;   % 晶粒中心坐标
            ori_x = the_grain.meanOrientation;  % 晶粒平均取向
            halfSideLength = the_grain.diameter*scale/2*1.08;
            
            % 将EBSD坐标转换为SEM图像坐标
            x_inSEM = center_xy(1)/p2_ebsd(1)*(p2_sem(1)-p1_sem(1))+p1_sem(1);
            y_inSEM = center_xy(2)/p2_ebsd(2)*(p2_sem(2)-p1_sem(2))+p1_sem(2);
            
            % 定义区域并选择落在该区域内的EBSD点
            region = [center_xy(1)-the_grain.diameter/2, center_xy(2)-the_grain.diameter/2, ...
                     the_grain.diameter, the_grain.diameter];
            condition = inpolygon(ebsd, region);
            
            %% 绘制晶粒详细信息
            figure(4)
            clf(4)
            set(gcf, 'Units', 'pixels', 'Position', [100, 100, 800, 800]);
            set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0, 10, 8, 8]);
            colors_the_grain = ipfKey.orientation2color(ebsd(condition).orientations);
            plot(ebsd(condition), colors_the_grain)
            
            hold on
            plot(the_grain.boundary, 'lineWidth', 2, 'lineColor', 'k')
            hold on
            
            %% 计算各类滑移系的迹线和施密特因子
            % 基面滑移
            sS_basal_this_grain = ori_x .* sSBasal;
            sS_basal_this_grain_trace = sS_basal_this_grain.trace;
            sSBasal_all_this_grain = ori_x .* sSBasal_all; % 施密特因子计算
            
            % 柱面滑移
            sSPrismatic_this_grain = ori_x .* sSPrismatic;
            sSPrismatic_this_grain_trace = sSPrismatic_this_grain.trace;
            
            % 锥面a滑移
            sSPyramidalA_this_grain = ori_x .* sSPyramidala;
            sSPyramidalA_this_grain_trace = sSPyramidalA_this_grain.trace;
            
            % 锥面c+a (I型)滑移
            sSPyramidalCA_this_grain = ori_x .* sSPyramidalca;
            sSPyramidalCA_this_grain_trace = sSPyramidalCA_this_grain.trace;
            
            % 锥面c+a (II型)滑移
            sSPyramidal2CA_this_grain = ori_x .* sSPyramidal2ca;
            sSPyramidal2CA_this_grain_trace = sSPyramidal2CA_this_grain.trace;
            
            %% 可视化滑移平面的迹线
            % 基面滑移迹线
            quiver(the_grain, sS_basal_this_grain.trace, 'color', my_c2(1,1))
            slop_trace(1) = sS_basal_this_grain_trace.y ./sS_basal_this_grain_trace.x;
            Sf(1) = max(abs(sSBasal_all_this_grain.SchmidFactor(sigma)));
            
            hold on
            % 柱面滑移迹线
            for i = 1:3
                quiver(the_grain, sSPrismatic_this_grain_trace(i), 'color', my_c2(3,i))
                hold on
            end
            slop_trace(2:4) = sSPrismatic_this_grain_trace.y ./ sSPrismatic_this_grain_trace.x;
            Sf(2:4) = sSPrismatic_this_grain.SchmidFactor(sigma);
            
            % 锥面a滑移迹线
            for i = 1:6
                quiver(the_grain, sSPyramidalA_this_grain_trace(i), 'color', my_c2(6,i))
                hold on
            end
            slop_trace(5:10) = sSPyramidalA_this_grain_trace.y ./ sSPyramidalA_this_grain_trace.x;
            Sf(5:10) = sSPyramidalA_this_grain.SchmidFactor(sigma);
            
            % 锥面c+a (I型)施密特因子
            % 注：迹线与锥面a相同，不重复绘制
            Sf(11:22) = sSPyramidalCA_this_grain.SchmidFactor(sigma);
            
            % 锥面c+a (II型)迹线
            for i = 1:6
                quiver(the_grain, sSPyramidal2CA_this_grain_trace(i), 'color', my_c2(9,i))
                hold on
            end
            slop_trace(11:16) = sSPyramidal2CA_this_grain_trace.y ./ sSPyramidal2CA_this_grain_trace.x;
            Sf(23:28) = sSPyramidalA_this_grain.SchmidFactor(sigma);
            
            %% 显示SEM图像中的对应区域
            figure(3);
            set(gcf, 'Units', 'pixels', 'Position', [100, 100, 800, 800]);
            set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0, 10, 8, 8]);
            clf(3);
            
            % 提取SEM图像中对应的区域
            sem_size = size(img);
            img_part = img(max(1,y_inSEM-halfSideLength):min(sem_size(1),y_inSEM+halfSideLength), ...
                          max(1, x_inSEM-halfSideLength):min(sem_size(2),x_inSEM+halfSideLength));
            
            % 显示SEM子图像
            imshow(img_part, 'InitialMagnification', 'fit', 'Interpolation', 'bilinear');
            hold on
            
            % 在SEM图像上叠加各类滑移系迹线
            quiver(the_grain, sS_basal_this_grain.trace, 'color', my_c2(1,1), 'scale', 10000)
            hold on
            
            for i = 1:3
                quiver(the_grain, sSPrismatic_this_grain_trace(i), 'color', my_c2(2,i))
                hold on
            end
            
            for i = 1:6
                quiver(the_grain, sSPyramidalA_this_grain_trace(i), 'color', my_c2(3,i))
                hold on
            end
            
            %% 用户交互：在SEM上标记观察到的滑移迹线
            [x1, y1] = ginput(1);
            plot(x1, y1, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
            
            [x2, y2] = ginput(1);
            plot(x2, y2, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
            hold on
            
            % 在全局SEM图像上标记当前分析的晶粒中心
            figure(2);
            plot(x_inSEM, y_inSEM, 'g+', 'MarkerSize', 10, 'LineWidth', 2);
            hold on
            
            %% 分析用户标记的滑移迹线
            % 计算欧几里得距离
            distance = sqrt((x2 - x1)^2 + (y2 - y1)^2);
            
            if distance < 10
                % 如果两点距离太近，认为无可见滑移迹线
                output(n_gra,3) = 1;
            else
                % 计算SEM图像中标记迹线的斜率
                slope = (y2 - y1) / (x2 - x1);
                
                % 记录晶粒的欧拉角和斜率信息
                output(n_gra,5) = rad2deg(ori_x.phi1); % 三个欧拉角
                output(n_gra,6) = rad2deg(ori_x.Phi);
                output(n_gra,7) = rad2deg(ori_x.phi2);
                output(n_gra,8) = slope;
                
                %% 计算SEM迹线与理论迹线的夹角
                theta_rad = atan(abs((slope - slop_trace) ./ (1 + slop_trace * slope)));
                theta_deg = rad2deg(theta_rad);
                
                % 确保夹角在0-90度之间
                for i = 1:length(theta_deg)
                    if theta_deg(i) > 90
                        theta_deg(i) = 180 - theta_deg(i);
                    end
                end
                
                %% 确定迹线的具体类型
                % 找出夹角小于7.5度的滑移系
                [~,ind_SSs] = find(theta_deg <= 7.5);
                
                if isempty(ind_SSs)
                    % 无匹配的滑移系
                    output(n_gra,3) = 999;
                    sf_actived_sS = 0;
                    index_ss_yes = 0;
                elseif sum(ismember(ind_SSs,2)) + sum(ismember(ind_SSs,3)) + sum(ismember(ind_SSs,4)) > 0
                    % 包含柱面的情况
                    index_ss_yes = pr_index(ind_SSs, Sf);
                    sf_actived_sS = Sf(index_ss_yes);
                elseif ismember(ind_SSs,1)
                    % 无柱面但包含基面滑移
                    [index_ss_yes, sf_actived_sS] = ba_index(Sf);
                else
                    % 无基面、无柱面的情况
                    % 判断锥面a、c+a type I和type II
                    [index_ss_yes, sf_actived_sS] = py_index(ind_SSs, Sf);
                end
                
                % 通过滑移系编号确定滑移类型
                type_id = ss_type(index_ss_yes);
                
                % 记录结果
                output(n_gra,2) = type_id;          % 滑移系类型编号
                output(n_gra,3) = index_ss_yes;     % 滑移系编号
                output(n_gra,4) = abs(sf_actived_sS); % 激活滑移系的施密特因子
                
                % 保存结果
                save(save_file_mat_name, 'output');
            end
            
            % mP值计算
            mP = mPrime(sSGrain(id_Ti_new(:,1)), sSGrain(id_Ti_new(:,2)));
        end
    end
end
