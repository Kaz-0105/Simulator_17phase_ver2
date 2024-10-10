function create(obj, property_name)
    if strcmp(property_name, 'RoadParameterMap')
        % RoadParameterMapの初期化
        obj.RoadParameterMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

        % Roadクラスを走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % links構造体を取得
            links = Road.get('links');

            % 車線数を取得
            num_lanes = links.main.lanes;

            % road_prm構造体を初期化
            road_prm = struct();

            % LaneParameterMapの初期化
            LaneParameterMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

            if num_lanes == 1
                % lane_prm構造体を初期化
                lane_prm = struct();

                % main_prm構造体を初期化
                main_prm = struct();

                % p_s（信号の位置）を設定
                main_prm.p_s = links.main.length;

                % v（速度）を設定
                main_prm.v = Road.get('speed');

                % D_o（評価範囲）を設定
                controllers = obj.Config.get('controllers');
                main_prm.D_o = controllers.MPC.D_o;

                % D_s（信号の影響圏）を設定
                main_prm.D_s = main_prm.v / 2;

                % d_s（停止線の距離）を設定
                main_prm.d_s = 0;

                % D_f（先行車の影響圏）を設定
                if main_prm.v >= 80
                    main_prm.D_f = main_prm.v;
                else
                    main_prm.D_f = main_prm.v/2;
                end

                % d_f（先行車との距離の最小値）を設定
                main_prm.d_f = 5;

                if isfield(links, 'branch')
                    if isfield(links.branch, 'right')
                        % branch構造体を取得
                        branch = links.branch.right;

                        % link構造体とconnector構造体に分割
                        link = branch.link;
                        connector = branch.connector;

                        % branch_prm構造体を初期化
                        branch_prm = struct();

                        % p_s（信号の位置）を設定
                        branch_prm.p_s = connector.from_pos + connector.length + link.length;

                        % v（速度）を設定
                        branch_prm.v = Road.get('speed');

                        % D_o（評価範囲）を設定
                        branch_prm.D_o = controllers.MPC.D_o;

                        % D_s（信号の影響圏）を設定
                        branch_prm.D_s = branch_prm.v / 2;

                        % d_s（停止線の距離）を設定
                        branch_prm.d_s = 0;

                        % D_f（先行車の影響圏）を設定
                        if branch_prm.v >= 80
                            branch_prm.D_f = branch_prm.v;
                        else
                            branch_prm.D_f = branch_prm.v/2;
                        end

                        % d_f（先行車との距離の最小値）を設定
                        branch_prm.d_f = 5;

                        % D_b（信号と分岐点の距離）を設定
                        main_prm.D_b = main_prm.p_s - connector.from_pos;
                        branch_prm.D_b = branch_prm.p_s - connector.from_pos;   

                        % main_prmとbranch_prmをlane_prmにプッシュ
                        lane_prm.main = main_prm;
                        lane_prm.branch.right = branch_prm;
                    end

                    if isfield(links.branch, 'left')
                        % branch構造体を取得
                        branch = links.branch.left;

                        % link構造体とconnector構造体に分割
                        link = branch.link;
                        connector = branch.connector;

                        % branch_prm構造体を初期化
                        branch_prm = struct();

                        % p_s（信号の位置）を設定
                        branch_prm.p_s = connector.from_pos + connector.length + link.length;

                        % v（速度）を設定
                        branch_prm.v = Road.get('speed');

                        % D_o（評価範囲）を設定
                        branch_prm.D_o = controllers.MPC.D_o;

                        % D_s（信号の影響圏）を設定
                        branch_prm.D_s = branch_prm.v / 2;

                        % d_s（停止線の距離）を設定
                        branch_prm.d_s = 0;

                        % D_f（先行車の影響圏）を設定
                        if branch_prm.v >= 80
                            branch_prm.D_f = branch_prm.v;
                        else
                            branch_prm.D_f = branch_prm.v/2;
                        end

                        % d_f（先行車との距離の最小値）を設定
                        branch_prm.d_f = 5;

                        % D_b（信号と分岐点の距離）を設定
                        main_prm.D_b = main_prm.p_s - connector.from_pos;
                        branch_prm.D_b = branch_prm.p_s - connector.from_pos;

                        % mainのパラメータが既に存在するかで場合分け
                        if isfield(lane_prm, 'main')
                            % D_b（信号と分岐点の距離）が小さい方を選択
                            if lane_prm.main.D_b > main_prm.D_b
                                lane_prm.main = main_prm;
                            end
                        else
                            % main_prmをlane_prmにプッシュ
                            lane_prm.main = main_prm;
                        end

                        % branch_prmをlane_prmにプッシュ
                        lane_prm.branch.left = branch_prm;
                    end

                else
                    % main_prmをlane_prmにプッシュ
                    lane_prm.main = main_prm;
                end

                % lane_prmをLaneParameterMapにプッシュ
                LaneParameterMap(1) = lane_prm;

                % LaneParameterMapをroad_prmにプッシュ
                road_prm.LaneParameterMap = LaneParameterMap;

                % road_prmをRoadParameterMapにプッシュ
                obj.RoadParameterMap(road_id) = road_prm;
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % lane_prm構造体を初期化
                    lane_prm = struct();

                    % main_prm構造体を初期化
                    main_prm = struct();

                    % p_s（信号の位置）を設定
                    main_prm.p_s = links.main.length;

                    % v（速度）を設定
                    main_prm.v = Road.get('speed');

                    % D_o（評価範囲）を設定
                    controllers = obj.Config.get('controllers');
                    main_prm.D_o = controllers.MPC.D_o;

                    % D_s（信号の影響圏）を設定
                    main_prm.D_s = main_prm.v / 2;

                    % d_s（停止線の距離）を設定
                    main_prm.d_s = 0;

                    % D_f（先行車の影響圏）を設定
                    if main_prm.v >= 80
                        main_prm.D_f = main_prm.v;
                    else
                        main_prm.D_f = main_prm.v/2;
                    end

                    % d_f（先行車との距離の最小値）を設定
                    main_prm.d_f = 5;

                    % 端の車線かどうかで場合分け
                    if lane_id == 1
                        % 右の分岐車線があるかどうか
                        if isfield(links, 'branch') 
                            if isfield(links.branch, 'right')
                                % branch構造体を取得
                                branch = links.branch.right;

                                % link構造体とconnector構造体に分割
                                link = branch.link;
                                connector = branch.connector;

                                % branch_prm構造体を初期化
                                branch_prm = struct();

                                % p_s（信号の位置）を設定
                                branch_prm.p_s = connector.from_pos + connector.length + link.length;

                                % v（速度）を設定
                                branch_prm.v = Road.get('speed');

                                % D_o（評価範囲）を設定
                                branch_prm.D_o = controllers.MPC.D_o;

                                % D_s（信号の影響圏）を設定
                                branch_prm.D_s = branch_prm.v / 2;

                                % d_s（停止線の距離）を設定
                                branch_prm.d_s = 0;

                                % D_f（先行車の影響圏）を設定
                                if branch_prm.v >= 80
                                    branch_prm.D_f = branch_prm.v;
                                else
                                    branch_prm.D_f = branch_prm.v/2;
                                end

                                % d_f（先行車との距離の最小値）を設定
                                branch_prm.d_f = 5;

                                % D_b（信号と分岐点の距離）を設定
                                main_prm.D_b = main_prm.p_s - connector.from_pos;
                                branch_prm.D_b = branch_prm.p_s - connector.from_pos;

                                % main_prmとbranch_prmをlane_prmにプッシュ
                                lane_prm.main = main_prm;
                                lane_prm.branch = branch_prm;
                            end
                        end

                    elseif lane_id == num_lanes
                        % 左の分岐車線があるかどうか
                        if isfield(links, 'branch')
                            if isfield(links.branch, 'left')
                                % branch構造体を取得
                                branch = links.branch.left;

                                % link構造体とconnector構造体に分割
                                link = branch.link;
                                connector = branch.connector;

                                % branch_prm構造体を初期化
                                branch_prm = struct();

                                % p_s（信号の位置）を設定
                                branch_prm.p_s = connector.from_pos + connector.length + link.length;

                                % v（速度）を設定
                                branch_prm.v = Road.get('speed');

                                % D_o（評価範囲）を設定
                                branch_prm.D_o = controllers.MPC.D_o;

                                % D_s（信号の影響圏）を設定
                                branch_prm.D_s = branch_prm.v / 2;

                                % d_s（停止線の距離）を設定
                                branch_prm.d_s = 0;

                                % D_f（先行車の影響圏）を設定
                                if branch_prm.v >= 80
                                    branch_prm.D_f = branch_prm.v;
                                else
                                    branch_prm.D_f = branch_prm.v/2;
                                end

                                % d_f（先行車との距離の最小値）を設定
                                branch_prm.d_f = 5;

                                % D_b（信号と分岐点の距離）を設定
                                main_prm.D_b = main_prm.p_s - connector.from_pos;
                                branch_prm.D_b = branch_prm.p_s - connector.from_pos;

                                % main_prmとbranch_prmをlane_prmにプッシュ
                                lane_prm.main = main_prm;
                                lane_prm.branch = branch_prm;
                            end
                        end
                    else
                        % main_prmをlane_prmにプッシュ
                        lane_prm.main = main_prm;
                    end

                    % lane_prmをLaneParameterMapにプッシュ
                    LaneParameterMap(lane_id) = lane_prm;
                end

                % LaneParameterMapをroad_prmにプッシュ
                road_prm.LaneParameterMap = LaneParameterMap;

                % road_prmをRoadParameterMapにプッシュ
                obj.RoadParameterMap(road_id) = road_prm;
            end
        end

    else
        error('Property name is invalid.');
    end
end