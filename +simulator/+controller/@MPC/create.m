function create(obj, property_name)
    if strcmp(property_name, 'RoadPrmMap')
        % RoadPrmMapの初期化
        obj.RoadPrmMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

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

            % LanePrmMapの初期化
            LanePrmMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

            % 速度を取得
            v_kmh = Road.get('speed');

            if num_lanes == 1
                % lane_prm構造体を初期化
                lane_prm = struct();

                % main_prm構造体を初期化
                main_prm = struct();

                % p_s（信号の位置）を設定
                main_prm.p_s = links.main.length;

                % v（速度）を設定
                main_prm.v = v_kmh/3.6;

                % D_o（評価範囲）を設定
                controllers = obj.Config.get('controllers');
                main_prm.D_o = controllers.Mpc.D_o;

                % D_s（信号の影響圏）を設定
                main_prm.D_s = v_kmh / 2;

                % d_s（停止線の距離）を設定
                main_prm.d_s = 0;

                % k_s（モデルに登場するパラメータ）を設定
                main_prm.k_s = 1/(main_prm.D_s - main_prm.d_s);

                % D_f（先行車の影響圏）を設定
                if v_kmh >= 80
                    main_prm.D_f = v_kmh;
                else
                    main_prm.D_f = v_kmh/2;
                end

                % d_f（先行車との距離の最小値）を設定
                main_prm.d_f = 5;

                % k_f（モデルに登場するパラメータ）を設定
                main_prm.k_f = 1/(main_prm.D_f - main_prm.d_f);

                % h_dを設定
                main_prm.h_d = @(p) (-p + main_prm.p_s - main_prm.D_s);

                % h_oを設定
                main_prm.h_o = @(p) (-p + main_prm.p_s - main_prm.D_o);

                % h_pを設定
                main_prm.h_p = @(p) (p - main_prm.p_s + main_prm.d_s);

                % h_fを設定 
                main_prm.h_f = @(p1, p2) (-p1 + p2 + main_prm.D_f);

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
                        branch_prm.v = v_kmh/3.6;

                        % D_o（評価範囲）を設定
                        branch_prm.D_o = controllers.Mpc.D_o;

                        % D_s（信号の影響圏）を設定
                        branch_prm.D_s = v_kmh / 2;

                        % d_s（停止線の距離）を設定
                        branch_prm.d_s = 0;

                        % k_s（モデルに登場するパラメータ）を設定
                        branch_prm.k_s = 1/(branch_prm.D_s - branch_prm.d_s);

                        % D_f（先行車の影響圏）を設定
                        if v_kmh >= 80
                            branch_prm.D_f = v_kmh;
                        else
                            branch_prm.D_f = v_kmh/2;
                        end

                        % d_f（先行車との距離の最小値）を設定
                        branch_prm.d_f = 5;

                        % k_f（モデルに登場するパラメータ）を設定
                        branch_prm.k_f = 1/(branch_prm.D_f - branch_prm.d_f);

                        % h_dを設定
                        branch_prm.h_d = @(p) (-p + branch_prm.p_s - branch_prm.D_s);

                        % h_oを設定
                        branch_prm.h_o = @(p) (-p + branch_prm.p_s - branch_prm.D_o);

                        % h_pを設定
                        branch_prm.h_p = @(p) (p - branch_prm.p_s + branch_prm.d_s);

                        % h_fを設定
                        branch_prm.h_f = @(p1, p2) (-p1 + p2 + branch_prm.D_f);

                        % D_b（信号と分岐点の距離）を設定
                        main_prm.D_b = main_prm.p_s - connector.from_pos;
                        branch_prm.D_b = branch_prm.p_s - connector.from_pos;
                        
                        % h_bを設定
                        main_prm.h_b = @(p) (-p + main_prm.p_s - main_prm.D_b);
                        branch_prm.h_b = @(p) (-p + branch_prm.p_s - branch_prm.D_b);

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
                        branch_prm.v = v_kmh/3.6;

                        % D_o（評価範囲）を設定
                        branch_prm.D_o = controllers.Mpc.D_o;

                        % D_s（信号の影響圏）を設定
                        branch_prm.D_s = v_kmh / 2;

                        % d_s（停止線の距離）を設定
                        branch_prm.d_s = 0;

                        % k_s（モデルに登場するパラメータ）を設定
                        branch_prm.k_s = 1/(branch_prm.D_s - branch_prm.d_s);

                        % D_f（先行車の影響圏）を設定
                        if v_kmh >= 80
                            branch_prm.D_f = v_kmh;
                        else
                            branch_prm.D_f = v_kmh/2;
                        end

                        % d_f（先行車との距離の最小値）を設定
                        branch_prm.d_f = 5;

                        % k_f（モデルに登場するパラメータ）を設定
                        branch_prm.k_f = 1/(branch_prm.D_f - branch_prm.d_f);

                        % h_dを設定
                        branch_prm.h_d = @(p) (-p + branch_prm.p_s - branch_prm.D_s);

                        % h_oを設定
                        branch_prm.h_o = @(p) (-p + branch_prm.p_s - branch_prm.D_o);

                        % h_pを設定
                        branch_prm.h_p = @(p) (p - branch_prm.p_s + branch_prm.d_s);

                        % h_fを設定
                        branch_prm.h_f = @(p1, p2) (-p1 + p2 + branch_prm.D_f);

                        % D_b（信号と分岐点の距離）を設定
                        main_prm.D_b = main_prm.p_s - connector.from_pos;
                        branch_prm.D_b = branch_prm.p_s - connector.from_pos;

                        % h_bを設定
                        main_prm.h_b = @(p) (-p + main_prm.p_s - main_prm.D_b);
                        branch_prm.h_b = @(p) (-p + branch_prm.p_s - branch_prm.D_b);

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

                % lane_prmをLanePrmMapにプッシュ
                LanePrmMap(1) = lane_prm;

                % LanePrmMapをroad_prmにプッシュ
                road_prm.LanePrmMap = LanePrmMap;

                % road_prmをRoadPrmMapにプッシュ
                obj.RoadPrmMap(road_id) = road_prm;
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
                    main_prm.v = v_kmh/3.6;

                    % D_o（評価範囲）を設定
                    controllers = obj.Config.get('controllers');
                    main_prm.D_o = controllers.Mpc.D_o;

                    % D_s（信号の影響圏）を設定
                    main_prm.D_s = v_kmh / 2;

                    % d_s（停止線の距離）を設定
                    main_prm.d_s = 0;

                    % k_s（モデルに登場するパラメータ）を設定
                    main_prm.k_s = 1/(main_prm.D_s - main_prm.d_s);

                    % D_f（先行車の影響圏）を設定
                    if v_kmh >= 80
                        main_prm.D_f = v_kmh;
                    else
                        main_prm.D_f = v_kmh/2;
                    end

                    % d_f（先行車との距離の最小値）を設定
                    main_prm.d_f = 5;

                    % k_f（モデルに登場するパラメータ）を設定
                    main_prm.k_f = 1/(main_prm.D_f - main_prm.d_f);

                    % h_dを設定
                    main_prm.h_d = @(p) (-p + main_prm.p_s - main_prm.D_s);

                    % h_oを設定
                    main_prm.h_o = @(p) (-p + main_prm.p_s - main_prm.D_o);

                    % h_pを設定
                    main_prm.h_p = @(p) (p - main_prm.p_s + main_prm.d_s);

                    % h_fを設定
                    main_prm.h_f = @(p1, p2) (-p1 + p2 + main_prm.D_f);

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
                                branch_prm.v = v_kmh/3.6;

                                % D_o（評価範囲）を設定
                                branch_prm.D_o = controllers.Mpc.D_o;

                                % D_s（信号の影響圏）を設定
                                branch_prm.D_s = v_kmh / 2;

                                % d_s（停止線の距離）を設定
                                branch_prm.d_s = 0;

                                % k_s（モデルに登場するパラメータ）を設定
                                branch_prm.k_s = 1/(branch_prm.D_s - branch_prm.d_s);

                                % D_f（先行車の影響圏）を設定
                                if v_kmh >= 80
                                    branch_prm.D_f = v_kmh;
                                else
                                    branch_prm.D_f = v_kmh/2;
                                end

                                % d_f（先行車との距離の最小値）を設定
                                branch_prm.d_f = 5;

                                % k_f（モデルに登場するパラメータ）を設定
                                branch_prm.k_f = 1/(branch_prm.D_f - branch_prm.d_f);

                                % h_dを設定
                                branch_prm.h_d = @(p) (-p + branch_prm.p_s - branch_prm.D_s);

                                % h_oを設定
                                branch_prm.h_o = @(p) (-p + branch_prm.p_s - branch_prm.D_o);

                                % h_pを設定
                                branch_prm.h_p = @(p) (p - branch_prm.p_s + branch_prm.d_s);

                                % h_fを設定
                                branch_prm.h_f = @(p1, p2) (-p1 + p2 + branch_prm.D_f);

                                % D_b（信号と分岐点の距離）を設定
                                main_prm.D_b = main_prm.p_s - connector.from_pos;
                                branch_prm.D_b = branch_prm.p_s - connector.from_pos;

                                % h_bを設定
                                main_prm.h_b = @(p) (-p + main_prm.p_s - main_prm.D_b);
                                branch_prm.h_b = @(p) (-p + branch_prm.p_s - branch_prm.D_b);

                                % main_prmとbranch_prmをlane_prmにプッシュ
                                lane_prm.main = main_prm;
                                lane_prm.branch = branch_prm;
                            else
                                % main_prmをlane_prmにプッシュ
                                lane_prm.main = main_prm;
                            end
                        else
                            % main_prmをlane_prmにプッシュ
                            lane_prm.main = main_prm;
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
                                branch_prm.v = v_kmh/3.6;

                                % D_o（評価範囲）を設定
                                branch_prm.D_o = controllers.Mpc.D_o;

                                % D_s（信号の影響圏）を設定
                                branch_prm.D_s = v_kmh / 2;

                                % d_s（停止線の距離）を設定
                                branch_prm.d_s = 0;

                                % k_s（モデルに登場するパラメータ）を設定
                                branch_prm.k_s = 1/(branch_prm.D_s - branch_prm.d_s);

                                % D_f（先行車の影響圏）を設定
                                if v_kmh >= 80
                                    branch_prm.D_f = v_kmh;
                                else
                                    branch_prm.D_f = v_kmh/2;
                                end

                                % d_f（先行車との距離の最小値）を設定
                                branch_prm.d_f = 5;

                                % k_f（モデルに登場するパラメータ）を設定
                                branch_prm.k_f = 1/(branch_prm.D_f - branch_prm.d_f);

                                % h_dを設定
                                branch_prm.h_d = @(p) (-p + branch_prm.p_s - branch_prm.D_s);

                                % h_oを設定
                                branch_prm.h_o = @(p) (-p + branch_prm.p_s - branch_prm.D_o);

                                % h_pを設定
                                branch_prm.h_p = @(p) (p - branch_prm.p_s + branch_prm.d_s);

                                % h_fを設定
                                branch_prm.h_f = @(p1, p2) (-p1 + p2 + branch_prm.D_f);

                                % D_b（信号と分岐点の距離）を設定
                                main_prm.D_b = main_prm.p_s - connector.from_pos;
                                branch_prm.D_b = branch_prm.p_s - connector.from_pos;

                                % h_bを設定
                                main_prm.h_b = @(p) (-p + main_prm.p_s - main_prm.D_b);
                                branch_prm.h_b = @(p) (-p + branch_prm.p_s - branch_prm.D_b);

                                % main_prmとbranch_prmをlane_prmにプッシュ
                                lane_prm.main = main_prm;
                                lane_prm.branch = branch_prm;
                            else
                                % main_prmをlane_prmにプッシュ
                                lane_prm.main = main_prm;
                            end
                        else
                            % main_prmをlane_prmにプッシュ
                            lane_prm.main = main_prm;
                        end
                    else
                        % main_prmをlane_prmにプッシュ
                        lane_prm.main = main_prm;
                    end

                    % lane_prmをLanePrmMapにプッシュ
                    LanePrmMap(lane_id) = lane_prm;
                end

                % LanePrmMapをroad_prmにプッシュ
                road_prm.LanePrmMap = LanePrmMap;

                % road_prmをRoadPrmMapにプッシュ
                obj.RoadPrmMap(road_id) = road_prm;
            end
        end

    else
        error('Property name is invalid.');
    end
end