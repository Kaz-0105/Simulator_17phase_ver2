function updateMLD(obj, property_name)
    if strcmp(property_name, 'A')
        % A行列の初期化
        A = [];

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % 車線数を取得
            links = Road.get('links');
            num_lanes = links.main.lanes;

            % 車線の数で場合分け
            if num_lanes == 1  
                % 自動車台数を取得
                num_vehicles = height(vehicles);

                % tmp_A行列を作成
                tmp_A = eye(num_vehicles);

                % A行列にプッシュ
                A = blkdiag(A, tmp_A);

            else    
                % 車線を走査
                for lane_id = 1: num_lanes
                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % 自動車台数を取得
                    num_vehicles = height(tmp_vehicles);

                    % tmp_A行列の作成
                    tmp_A = eye(num_vehicles);

                    % A行列にプッシュ
                    A = blkdiag(A, tmp_A);
                end
            end
        end

        % MLDsMapにA行列をプッシュ
        obj.MLDsMap('A') = A;

    elseif strcmp(property_name, 'B1')
        % B1行列を初期化
        B1 = [];

        % num_roadsを取得
        num_roads = obj.Roads.count();

        % 道路を走査
        for road_id = 1: num_roads
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % 車線数を取得
            road_prm = obj.RoadPrmMap(road_id);
            num_lanes = road_prm.LanePrmMap.Count();

            % num_signalsを取得
            num_signals = num_roads * (num_roads - 1);

            % 車線の数で場合分け
            if num_lanes == 1
                % 自動車台数を取得
                num_vehicles = height(vehicles);

                % tmp_B1行列を作成
                tmp_B1 = zeros(num_vehicles, num_signals);

                % B1行列にプッシュ
                B1 = [B1; tmp_B1];
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % 自動車台数を取得
                    num_vehicles = height(tmp_vehicles);

                    % tmp_B1行列の作成
                    tmp_B1 = zeros(num_vehicles, num_signals);

                    % B1行列にプッシュ
                    B1 = [B1; tmp_B1];
                end
            end
        end

        % MLDsMapにB1行列をプッシュ
        obj.MLDsMap('B1') = B1;

    elseif strcmp(property_name, 'B2')
        % B2行列を初期化
        B2 = [];

        % dtを取得
        dt = obj.dt;

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数を取得
            num_lanes = LanePrmMap.Count();

            % 車線の数で場合分け
            if num_lanes == 1
                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % tmp_B2行列を初期化
                tmp_B2 = [];

                % 車線分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')

                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % branch_flagによって場合分け
                        if vehicle.branch_flag == 1
                            % メインの車線のパラメータを取得
                            v = lane_prm.main.v;
                            k_s = lane_prm.main.k_s;
                            k_f = lane_prm.main.k_f;
                        elseif vehicle.branch_flag == 2
                            % 分岐車線のパラメータを取得
                            v = lane_prm.branch.right.v;
                            k_s = lane_prm.branch.right.k_s;
                            k_f = lane_prm.branch.right.k_f;
                        elseif vehicle.branch_flag == 3
                            % 分岐車線のパラメータを取得
                            v = lane_prm.branch.left.v;
                            k_s = lane_prm.branch.left.k_s;
                            k_f = lane_prm.branch.left.k_f;
                        else
                            error('branch_flag is invalid.');
                        end

                        % 先頭車かどうかで場合分け
                        if vehicle.leader_flag == 1
                            % b2を作成
                            b2 = -dt *v *k_s;
                        elseif vehicle.leader_flag == 2
                            % b2を作成
                            b2 = dt *v *[-k_s, k_f, -k_f];
                        elseif vehicle.leader_flag == 3
                            % b2を作成
                            b2 = dt *v *[-k_s, k_f, -k_f, k_f, -k_f];
                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_B2行列にプッシュ
                        tmp_B2 = blkdiag(tmp_B2, b2);
                    end
                else
                    % メインの車線のパラメータを取得
                    v = lane_prm.main.v;
                    k_s = lane_prm.main.k_s;
                    k_f = lane_prm.main.k_f;

                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % 先頭車かどうかで場合分け
                        if vehicle.leader_flag == 1
                            % b2を作成
                            b2 = -dt *v *k_s;
                        elseif vehicle.leader_flag == 3
                            % b2を作成
                            b2 = dt *v *[-k_s, k_f, -k_f];
                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_B2行列にプッシュ
                        tmp_B2 = blkdiag(tmp_B2, b2);
                    end
                end

                % B2行列にプッシュ
                B2 = blkdiag(B2, tmp_B2);
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % lane_prmを取得
                    lane_prm = LanePrmMap(lane_id);

                    % tmp_B2行列を初期化
                    tmp_B2 = [];

                    % 車線分岐があるかどうかで場合分け
                    if isfield(lane_prm, 'branch')
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % branch_flagによって場合分け
                            if vehicle.branch_flag == 1
                                % メインの車線のパラメータを取得
                                v = lane_prm.main.v;
                                k_s = lane_prm.main.k_s;
                                k_f = lane_prm.main.k_f;
                            else
                                % 分岐車線のパラメータを取得
                                v = lane_prm.branch.v;
                                k_s = lane_prm.branch.k_s;
                                k_f = lane_prm.branch.k_f;
                            end

                            % 先頭車かどうかで場合分け
                            if vehicle.leader_flag == 1
                                % b2を作成
                                b2 = -dt *v *k_s;  
                            elseif vehicle.leader_flag == 2
                                % b2を作成
                                b2 = dt *v *[-k_s, k_f, -k_f];
                            elseif vehicle.leader_flag == 3
                                % b2を作成
                                b2 = dt *v *[-k_s, k_f, -k_f, k_f, -k_f];
                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_B2行列にプッシュ
                            tmp_B2 = blkdiag(tmp_B2, b2);
                        end
                    else
                        % メインの車線のパラメータを取得
                        v = lane_prm.main.v;
                        k_s = lane_prm.main.k_s;
                        k_f = lane_prm.main.k_f;

                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % 先頭車かどうかで場合分け
                            if vehicle.leader_flag == 1
                                b2 = -dt *v *k_s;
                            elseif vehicle.leader_flag == 3
                                b2 = dt *v *[-k_s, k_f, -k_f];
                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_B2行列にプッシュ
                            tmp_B2 = blkdiag(tmp_B2, b2);
                        end
                    end

                    % B2行列にプッシュ
                    B2 = blkdiag(B2, tmp_B2);
                end
            end

        end

        % B2行列にプッシュ
        obj.MLDsMap('B2') = B2;

    elseif strcmp(property_name, 'B3')
        % B3行列を初期化
        B3 = [];

        % dtを取得
        dt = obj.dt;

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数を取得
            num_lanes = LanePrmMap.Count();

            % 車線の数で場合分け
            if num_lanes == 1
                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % tmp_B3行列を初期化
                tmp_B3 = [];

                % 車線分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % branch_flagによって場合分け
                        if vehicle.branch_flag == 1
                            % メインの車線のパラメータを取得
                            v = lane_prm.main.v;
                            p_s = lane_prm.main.p_s;
                            d_s = lane_prm.main.d_s;
                            k_s = lane_prm.main.k_s;
                            d_f = lane_prm.main.d_f;
                            k_f = lane_prm.main.k_f;
                        elseif vehicle.branch_flag == 2
                            % 分岐車線のパラメータを取得
                            v = lane_prm.branch.right.v;
                            p_s = lane_prm.branch.right.p_s;
                            d_s = lane_prm.branch.right.d_s;
                            k_s = lane_prm.branch.right.k_s;
                            d_f = lane_prm.branch.right.d_f;
                            k_f = lane_prm.branch.right.k_f;
                        elseif vehicle.branch_flag == 3
                            % 分岐車線のパラメータを取得
                            v = lane_prm.branch.left.v;
                            p_s = lane_prm.branch.left.p_s;
                            d_s = lane_prm.branch.left.d_s;
                            k_s = lane_prm.branch.left.k_s;
                            d_f = lane_prm.branch.left.d_f;
                            k_f = lane_prm.branch.left.k_f;
                        else
                            error('branch_flag is invalid.');
                        end

                        % 先頭車かどうかで場合分け
                        if vehicle.leader_flag == 1
                            % b3を作成
                            b3 = dt *v *[0, 0, 0, k_s*(p_s-d_s) - 1, 0, 1];
                        elseif vehicle.leader_flag == 2
                            % b3を作成
                            b3 = dt *v *[0, 0, 0, 0, 0, k_s*(p_s-d_s) - 1, -k_f*d_f - 1, 0, 1];
                        elseif vehicle.leader_flag == 3
                            % b3を作成
                            b3 = dt *v *[0, 0, 0, 0, 0, 0, k_s*(p_s-d_s) - 1, -k_f*d_f - 1, -k_f*d_f - 1, 0, 0, 0, 1];
                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_B3行列にプッシュ
                        tmp_B3 = blkdiag(tmp_B3, b3);
                    end
                else
                    % メインの車線のパラメータを取得
                    v = lane_prm.main.v;
                    p_s = lane_prm.main.p_s;
                    d_s = lane_prm.main.d_s;
                    k_s = lane_prm.main.k_s;
                    d_f = lane_prm.main.d_f;
                    k_f = lane_prm.main.k_f;

                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % 先頭車かどうかで場合分け
                        if vehicle.leader_flag == 1
                            % b3を作成
                            b3 = dt *v *[0, 0, 0, k_s*(p_s-d_s) - 1, 0, 1];
                        elseif vehicle.leader_flag == 3
                            % b3を作成
                            b3 = dt *v *[0, 0, 0, 0, k_s*(p_s-d_s) - 1, -k_f*d_f - 1, 0, 0, 0, 1];
                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_B3行列にプッシュ
                        tmp_B3 = blkdiag(tmp_B3, b3);
                    end
                end

                % B3行列にプッシュ
                B3 = blkdiag(B3, tmp_B3);
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % lane_prmを取得
                    lane_prm = LanePrmMap(lane_id);

                    % tmp_B3行列を初期化
                    tmp_B3 = [];

                    % 車線分岐があるかどうかで場合分け
                    if isfield(lane_prm, 'branch')
                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % branch_flagによって場合分け
                            if vehicle.branch_flag == 1
                                % メインの車線のパラメータを取得
                                v = lane_prm.main.v;
                                p_s = lane_prm.main.p_s;
                                d_s = lane_prm.main.d_s;
                                k_s = lane_prm.main.k_s;
                                d_f = lane_prm.main.d_f;
                                k_f = lane_prm.main.k_f;
                            else
                                % 分岐車線のパラメータを取得
                                v = lane_prm.branch.v;
                                p_s = lane_prm.branch.p_s;
                                d_s = lane_prm.branch.d_s;
                                k_s = lane_prm.branch.k_s;
                                d_f = lane_prm.branch.d_f;
                                k_f = lane_prm.branch.k_f;
                            end

                            % 先頭車かどうかで場合分け
                            if vehicle.leader_flag == 1
                                % b3を作成
                                b3 = dt *v *[0, 0, 0, k_s*(p_s-d_s) - 1, 0, 1];
                            elseif vehicle.leader_flag == 2
                                % b3を作成
                                b3 = dt *v *[0, 0, 0, 0, 0, k_s*(p_s-d_s) - 1, -k_f*d_f - 1, 0, 1];
                            elseif vehicle.leader_flag == 3
                                % b3を作成
                                b3 = dt *v *[0, 0, 0, 0, 0, 0, k_s*(p_s-d_s) - 1, -k_f*d_f - 1, -k_f*d_f - 1, 0, 0, 0, 1];
                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_B3行列にプッシュ
                            tmp_B3 = blkdiag(tmp_B3, b3);
                        end
                    else
                        % メインの車線のパラメータを取得
                        v = lane_prm.main.v;
                        p_s = lane_prm.main.p_s;
                        d_s = lane_prm.main.d_s;
                        k_s = lane_prm.main.k_s;
                        d_f = lane_prm.main.d_f;
                        k_f = lane_prm.main.k_f;

                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % 先頭車かどうかで場合分け
                            if vehicle.leader_flag == 1
                                % b3を作成
                                b3 = dt *v *[0, 0, 0, k_s*(p_s-d_s) - 1, 0, 1];
                            elseif vehicle.leader_flag == 3
                                % b3を作成
                                b3 = dt *v *[0, 0, 0, 0, k_s*(p_s-d_s) - 1, -k_f*d_f - 1, 0, 0, 0, 1];
                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_B3行列にプッシュ
                            tmp_B3 = blkdiag(tmp_B3, b3);
                        end
                    end

                    % B3行列にプッシュ
                    B3 = blkdiag(B3, tmp_B3);
                end
            end
        end

        % B3行列をプッシュ
        obj.MLDsMap('B3') = B3;
    elseif strcmp(property_name, 'C')
        % C行列を初期化
        C = [];

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % 車線数を取得
            links = Road.get('links');
            num_lanes = links.main.lanes;

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数で場合分け
            if num_lanes == 1
                % レコードの数を取得
                num_vehicles = height(vehicles);

                % tmp_C行列を初期化
                tmp_C = [];

                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % 分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')
                    % 自動者を走査
                    for record_id = 1: num_vehicles
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % c行列を初期化
                            c = zeros(18, num_vehicles);

                            % delta_dの定義
                            c(9, record_id) = 1;
                            c(10, record_id) = -1;

                            % delta_pの定義
                            c(11, record_id) = -1;
                            c(12, record_id) = 1;

                            % delta_oの定義
                            c(13, record_id) = 1;
                            c(14, record_id) = -1;

                            % z_1の定義
                            c(17, record_id) = 1;
                            c(18, record_id) = -1;

                        elseif vehicle.leader_flag == 2
                            % c行列を初期化
                            c = zeros(34, num_vehicles);

                            % delta_dの定義
                            c(13, record_id) = 1;
                            c(14, record_id) = -1;

                            % delta_pの定義
                            c(15, record_id) = -1;
                            c(16, record_id) = 1;

                            % delta_f2の定義
                            c(17, [record_id - 1, record_id]) = [1, -1];
                            c(18, [record_id - 1, record_id]) = [-1, 1];

                            % delta_bの定義
                            c(19, record_id) = 1;
                            c(20, record_id) = -1;

                            % delta_oの定義
                            c(21, record_id) = 1;
                            c(22, record_id) = -1;

                            % z_1の定義
                            c(25, record_id) = 1;
                            c(26, record_id) = -1;

                            % z_2の定義
                            c(29, record_id - 1) = 1;
                            c(30, record_id - 1) = -1;

                            % z_3の定義
                            c(33, record_id) = 1;
                            c(34, record_id) = -1;

                        elseif vehicle.leader_flag == 3
                            % c行列を初期化
                            c = zeros(56, num_vehicles);

                            % delta_dの定義
                            c(25, record_id) = 1;
                            c(26, record_id) = -1;

                            % delta_pの定義
                            c(27, record_id) = -1;
                            c(28, record_id) = 1;

                            % delta_f2の定義
                            c(29, [record_id - 1, record_id]) = [1, -1];
                            c(30, [record_id - 1, record_id]) = [-1, 1];

                            % 先行車のIDを取得
                            preceding_record_id = vehicle.preceding_record_id;

                            % delta_f3の定義
                            c(31, [preceding_record_id, record_id]) = [1, -1];
                            c(32, [preceding_record_id, record_id]) = [-1, 1];

                            % delta_bの定義
                            c(33, record_id) = 1;
                            c(34, record_id) = -1;

                            % delta_oの定義
                            c(35, record_id) = 1;
                            c(36, record_id) = -1;

                            % z_1の定義
                            c(39, record_id) = 1;
                            c(40, record_id) = -1;

                            % z_2の定義
                            c(43, record_id - 1) = 1;
                            c(44, record_id - 1) = -1;

                            % z_3の定義
                            c(47, record_id) = 1;
                            c(48, record_id) = -1;

                            % z_4の定義
                            c(51, preceding_record_id) = 1;
                            c(52, preceding_record_id) = -1;

                            % z_5の定義
                            c(55, record_id) = 1;
                            c(56, record_id) = -1;
                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_C行列にcをプッシュ
                        tmp_C = [tmp_C; c];
                    end
                else
                    % 自動車を走査
                    for record_id = 1: num_vehicles
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % c行列を初期化
                            c = zeros(18, num_vehicles);

                            % delta_dの定義
                            c(9, record_id) = 1;
                            c(10, record_id) = -1;

                            % delta_pの定義
                            c(11, record_id) = -1;
                            c(12, record_id) = 1;

                            % delta_oの定義
                            c(13, record_id) = 1;
                            c(14, record_id) = -1;

                            % z_1の定義
                            c(17, record_id) = 1;
                            c(18, record_id) = -1;

                        elseif vehicle.leader_flag == 3
                            % c行列を初期化
                            c = zeros(39, num_vehicles);

                            % delta_dの定義
                            c(20, record_id) = 1;
                            c(21, record_id) = -1;

                            % delta_pの定義
                            c(22, record_id) = -1;
                            c(23, record_id) = 1;

                            % delta_fの定義
                            c(24, [record_id - 1, record_id]) = [1, -1];
                            c(25, [record_id - 1, record_id]) = [-1, 1];

                            % delta_oの定義
                            c(26, record_id) = 1;
                            c(27, record_id) = -1;

                            % z_1の定義
                            c(30, record_id) = 1;
                            c(31, record_id) = -1;

                            % z_2の定義
                            c(34, record_id - 1) = 1;
                            c(35, record_id - 1) = -1;

                            % z_3の定義
                            c(38, record_id) = 1;
                            c(39, record_id) = -1;
                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_C行列にcをプッシュ
                        tmp_C = [tmp_C; c];
                    end
                end

                % C行列にプッシュ
                C = blkdiag(C, tmp_C);
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % lane_prmを取得
                    lane_prm = LanePrmMap(lane_id);

                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % レコードの数を取得
                    num_vehicles = height(tmp_vehicles);

                    % tmp_C行列を初期化
                    tmp_C = [];

                    % 車線分岐があるかどうかで場合分け
                    if isfield(lane_prm, 'branch')
                        % 自動車を走査
                        for record_id = 1: num_vehicles
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % c行列を初期化
                                c = zeros(18, num_vehicles);

                                % delta_dの定義
                                c(9, record_id) = 1;
                                c(10, record_id) = -1;

                                % delta_pの定義
                                c(11, record_id) = -1;
                                c(12, record_id) = 1;

                                % delta_oの定義
                                c(13, record_id) = 1;
                                c(14, record_id) = -1;

                                % z_1の定義
                                c(17, record_id) = 1;
                                c(18, record_id) = -1;

                            elseif vehicle.leader_flag == 2
                                % c行列を初期化
                                c = zeros(34, num_vehicles);

                                % delta_dの定義
                                c(13, record_id) = 1;
                                c(14, record_id) = -1;

                                % delta_pの定義
                                c(15, record_id) = -1;
                                c(16, record_id) = 1;

                                % delta_f2の定義
                                c(17, [record_id - 1, record_id]) = [1, -1];
                                c(18, [record_id - 1, record_id]) = [-1, 1];

                                % delta_bの定義
                                c(19, record_id) = 1;
                                c(20, record_id) = -1;

                                % delta_oの定義
                                c(21, record_id) = 1;
                                c(22, record_id) = -1;

                                % z_1の定義
                                c(25, record_id) = 1;
                                c(26, record_id) = -1;

                                % z_2の定義
                                c(29, record_id - 1) = 1;
                                c(30, record_id - 1) = -1;

                                % z_3の定義
                                c(33, record_id) = 1;
                                c(34, record_id) = -1;

                            elseif vehicle.leader_flag == 3
                                % c行列を初期化
                                c = zeros(56, num_vehicles);

                                % delta_dの定義
                                c(25, record_id) = 1;
                                c(26, record_id) = -1;

                                % delta_pの定義
                                c(27, record_id) = -1;
                                c(28, record_id) = 1;

                                % delta_f2の定義
                                c(29, [record_id - 1, record_id]) = [1, -1];
                                c(30, [record_id - 1, record_id]) = [-1, 1];

                                % 先行車のIDを取得
                                preceding_record_id = vehicle.preceding_record_id;

                                % delta_f3の定義
                                c(31, [preceding_record_id, record_id]) = [1, -1];
                                c(32, [preceding_record_id, record_id]) = [-1, 1];

                                % delta_bの定義
                                c(33, record_id) = 1;
                                c(34, record_id) = -1;

                                % delta_oの定義
                                c(35, record_id) = 1;
                                c(36, record_id) = -1;

                                % z_1の定義
                                c(39, record_id) = 1;
                                c(40, record_id) = -1;

                                % z_2の定義
                                c(43, record_id - 1) = 1;
                                c(44, record_id - 1) = -1;

                                % z_3の定義
                                c(47, record_id) = 1;
                                c(48, record_id) = -1;

                                % z_4の定義
                                c(51, preceding_record_id) = 1;
                                c(52, preceding_record_id) = -1;

                                % z_5の定義
                                c(55, record_id) = 1;
                                c(56, record_id) = -1;
                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_C行列にcをプッシュ
                            tmp_C = [tmp_C; c];
                        end
                    else
                        % 自動車を走査
                        for record_id = 1: num_vehicles
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % c行列を初期化
                                c = zeros(18, num_vehicles);
    
                                % delta_dの定義
                                c(9, record_id) = 1;
                                c(10, record_id) = -1;
    
                                % delta_pの定義
                                c(11, record_id) = -1;
                                c(12, record_id) = 1;
    
                                % delta_oの定義
                                c(13, record_id) = 1;
                                c(14, record_id) = -1;
    
                                % z_1の定義
                                c(17, record_id) = 1;
                                c(18, record_id) = -1;
    
                            elseif vehicle.leader_flag == 3
                                % c行列を初期化
                                c = zeros(39, num_vehicles);
    
                                % delta_dの定義
                                c(20, record_id) = 1;
                                c(21, record_id) = -1;
    
                                % delta_pの定義
                                c(22, record_id) = -1;
                                c(23, record_id) = 1;
    
                                % delta_fの定義
                                c(24, [record_id - 1, record_id]) = [1, -1];
                                c(25, [record_id - 1, record_id]) = [-1, 1];
    
                                % delta_oの定義
                                c(26, record_id) = 1;
                                c(27, record_id) = -1;
    
                                % z_1の定義
                                c(30, record_id) = 1;
                                c(31, record_id) = -1;
    
                                % z_2の定義
                                c(34, record_id - 1) = 1;
                                c(35, record_id - 1) = -1;
    
                                % z_3の定義
                                c(38, record_id) = 1;
                                c(39, record_id) = -1;
                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_C行列にcをプッシュ
                            tmp_C = [tmp_C; c];
                        end
                    end

                    % C行列にプッシュ
                    C = blkdiag(C, tmp_C);
                end
            end
        end

        % C行列をプッシュ
        obj.MLDsMap('C') = C;

    elseif strcmp(property_name, 'D1')
        % D1行列を初期化
        D1 = [];

        % 道路数を取得
        num_roads = obj.Roads.count();

        % num_signalsを取得
        num_signals = num_roads * (num_roads - 1);

        % 道路を走査
        for road_id = 1: num_roads
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % 車線数を取得
            links = Road.get('links');
            num_lanes = links.main.lanes;

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数で場合分け
            if num_lanes == 1
                % tmp_D1行列を初期化
                tmp_D1 = [];

                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % 分岐があるかどうかで場合分け
                if isfield(lane_prm.branch)
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % signal_idを取得
                        signal_id = (num_roads - 1) * (road_id - 1) + vehicle.route;

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % d1行列を初期化
                            d1 = zeros(18, num_signals);

                            % delta_1の定義
                            d1(1, signal_id) = -1;
                            d1(2, signal_id) = 1;

                            % delta_t1の定義
                            d1(5, signal_id) = -1;
                            d1(6, signal_id) = 1;

                        elseif vehicle.leader_flag == 2
                            % d1行列を初期化
                            d1 = zeros(34, num_signals);

                            % delta_1の定義
                            d1(1, signal_id) = -1;
                            d1(2, signal_id) = 1;

                            % delta_t1の定義
                            d1(9, signal_id) = -1;
                            d1(10, signal_id) = 1;

                        elseif vehicle.leader_flag == 3
                            % d1行列を初期化
                            d1 = zeros(56, num_signals);

                            % delta_1の定義
                            d1(1, signal_id) = -1;
                            d1(2, signal_id) = 1;

                            % delta_t1の定義
                            d1(13, signal_id) = -1;
                            d1(14, signal_id) = 1;

                            % delta_t2の定義
                            d1(17, signal_id) = 1;
                            d1(19, signal_id) = -1;
                            
                        else
                            error('leader_flag is invalid.');
                        end

                        % d1行列をtmp_D1行列にプッシュ
                        tmp_D1 = [tmp_D1; d1];
                    end
                else
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % signal_idを取得
                        signal_id = (num_roads - 1) * (road_id - 1) + vehicle.route;

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % d1行列を初期化
                            d1 = zeros(18, num_signals);

                            % delta_1の定義
                            d1(1, signal_id) = -1;
                            d1(2, signal_id) = 1;

                            % delta_t1の定義
                            d1(5, signal_id) = -1;
                            d1(6, signal_id) = 1;

                            
                        elseif vehicle.leader_flag == 3
                            % d1行列を初期化
                            d1 = zeros(39, num_signals);

                            % delta_1の定義
                            d1(1, signal_id) = -1;
                            d1(2, signal_id) = 1;

                            % delta_t1の定義
                            d1(8, signal_id) = -1;
                            d1(9, signal_id) = 1;

                            % delta_t2の定義
                            d1(12, signal_id) = 1;
                            d1(14, signal_id) = -1;

                        else
                            error('leader_flag is invalid.');
                        end

                        % d1行列をtmp_D1行列にプッシュ
                        tmp_D1 = [tmp_D1; d1];
                    end
                end

                % D1行列にプッシュ
                D1 = [D1, tmp_D1];

            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % tmp_D1行列を初期化
                    tmp_D1 = [];

                    % lane_prmを取得
                    lane_prm = LanePrmMap(lane_id);

                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % 分岐があるかどうかで場合分け
                    if isfield(lane_prm, 'branch')
                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % signal_idを取得
                            signal_id = (num_roads - 1) * (road_id - 1) + vehicle.route;

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % d1行列を初期化
                                d1 = zeros(18, num_signals);

                                % delta_1の定義
                                d1(1, signal_id) = -1;
                                d1(2, signal_id) = 1;

                                % delta_t1の定義
                                d1(5, signal_id) = -1;
                                d1(6, signal_id) = 1;

                            elseif vehicle.leader_flag == 2
                                % d1行列を初期化
                                d1 = zeros(34, num_signals);

                                % delta_1の定義
                                d1(1, signal_id) = -1;
                                d1(2, signal_id) = 1;

                                % delta_t1の定義
                                d1(9, signal_id) = -1;
                                d1(10, signal_id) = 1;

                            elseif vehicle.leader_flag == 3
                                % d1行列を初期化
                                d1 = zeros(56, num_signals);

                                % delta_1の定義
                                d1(1, signal_id) = -1;
                                d1(2, signal_id) = 1;

                                % delta_t1の定義
                                d1(13, signal_id) = -1;
                                d1(14, signal_id) = 1;

                                % delta_t2の定義
                                d1(17, signal_id) = 1;
                                d1(19, signal_id) = -1;
                                
                            else
                                error('leader_flag is invalid.');
                            end

                            % d1行列をtmp_D1行列にプッシュ
                            tmp_D1 = [tmp_D1; d1];
                        end
                    else
                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % signal_idを取得
                            signal_id = (num_roads - 1) * (road_id - 1) + vehicle.route;

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % d1行列を初期化
                                d1 = zeros(18, num_signals);

                                % delta_1の定義
                                d1(1, signal_id) = -1;
                                d1(2, signal_id) = 1;

                                % delta_t1の定義
                                d1(5, signal_id) = -1;
                                d1(6, signal_id) = 1;

                            elseif vehicle.leader_flag == 3
                                % d1行列を初期化
                                d1 = zeros(39, num_signals);

                                % delta_1の定義
                                d1(1, signal_id) = -1;
                                d1(2, signal_id) = 1;

                                % delta_t1の定義
                                d1(8, signal_id) = -1;
                                d1(9, signal_id) = 1;

                                % delta_t2の定義
                                d1(12, signal_id) = 1;
                                d1(14, signal_id) = -1;
                                
                            else
                                error('leader_flag is invalid.');
                            end

                            % d1行列をtmp_D1行列にプッシュ
                            tmp_D1 = [tmp_D1; d1];
                        end
                    end

                    % D1行列にプッシュ
                    D1 = [D1; tmp_D1];
                end
            end
        end

        % D1行列をプッシュ
        obj.MLDsMap('D1') = D1;

    elseif strcmp(property_name, 'D2')

        % D2行列を初期化
        D2 = [];

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数を取得
            num_lanes = LanePrmMap.Count();

            % 車線数で場合分け
            if num_lanes == 1
                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % tmp_D2行列を初期化
                tmp_D2 = [];

                % 分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % d2行列を初期化
                            d2 = zeros(18, 1);

                            % z_1の定義
                            d2(15, 1) = -1;
                            d2(16, 1) = 1;
                            d2(17, 1) = -1;
                            d2(18, 1) = 1;

                        elseif vehicle.leader_flag == 2
                            % d2行列を初期化
                            d2 = zeros(34, 3);

                            % z_1の定義
                            d2(23, 1) = -1;
                            d2(24, 1) = 1;
                            d2(25, 1) = -1;
                            d2(26, 1) = 1;

                            % z_2の定義
                            d2(27, 2) = -1;
                            d2(28, 2) = 1;
                            d2(29, 2) = -1;
                            d2(30, 2) = 1;

                            % z_3の定義
                            d2(31, 3) = -1;
                            d2(32, 3) = 1;
                            d2(33, 3) = -1;
                            d2(34, 3) = 1;

                        elseif vehicle.leader_flag == 3
                            % d2行列を初期化
                            d2 = zeros(56, 5);

                            % z_1の定義
                            d2(37, 1) = -1;
                            d2(38, 1) = 1;
                            d2(39, 1) = -1;
                            d2(40, 1) = 1;

                            % z_2の定義
                            d2(41, 2) = -1;
                            d2(42, 2) = 1;
                            d2(43, 2) = -1;
                            d2(44, 2) = 1;

                            % z_3の定義
                            d2(45, 3) = -1;
                            d2(46, 3) = 1;
                            d2(47, 3) = -1;
                            d2(48, 3) = 1;

                            % z_4の定義
                            d2(49, 4) = -1;
                            d2(50, 4) = 1;
                            d2(51, 4) = -1;
                            d2(52, 4) = 1;

                            % z_5の定義
                            d2(53, 5) = -1;
                            d2(54, 5) = 1;
                            d2(55, 5) = -1;
                            d2(56, 5) = 1;

                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_D2行列にd2をプッシュ
                        tmp_D2 = blkdiag(tmp_D2, d2);
                    end
                else
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % d2行列を初期化
                            d2 = zeros(18, 1);

                            % z_1の定義
                            d2(15, 1) = -1;
                            d2(16, 1) = 1;  
                            d2(17, 1) = -1;
                            d2(18, 1) = 1;

                        elseif vehicle.leader_flag == 3
                            % d2行列を初期化
                            d2 = zeros(39, 3);

                            % z_1の定義
                            d2(28, 1) = -1;
                            d2(29, 1) = 1;
                            d2(30, 1) = -1;
                            d2(31, 1) = 1;

                            % z_2の定義
                            d2(32, 2) = -1;
                            d2(33, 2) = 1;
                            d2(34, 2) = -1;
                            d2(35, 2) = 1;

                            % z_3の定義
                            d2(36, 3) = -1;
                            d2(37, 3) = 1;
                            d2(38, 3) = -1;
                            d2(39, 3) = 1;

                        else
                            error('leader_flag is invalid.');
                        end

                        % tmp_D2行列にd2をプッシュ
                        tmp_D2 = blkdiag(tmp_D2, d2);   
                    end
                end

                % D2行列にプッシュ
                D2 = blkdiag(D2, tmp_D2);
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % lane_prmを取得
                    lane_prm = LanePrmMap(lane_id);

                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % tmp_D2行列を初期化
                    tmp_D2 = [];

                    % 分岐があるかどうかで場合分け
                    if isfield(lane_prm, 'branch')
                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % d2行列を初期化
                                d2 = zeros(18, 1);

                                % z_1の定義
                                d2(15, 1) = -1;
                                d2(16, 1) = 1;
                                d2(17, 1) = -1;
                                d2(18, 1) = 1;
                            elseif vehicle.leader_flag == 2
                                % d2行列を初期化
                                d2 = zeros(34, 3);

                                % z_1の定義
                                d2(23, 1) = -1;
                                d2(24, 1) = 1;
                                d2(25, 1) = -1;
                                d2(26, 1) = 1;

                                % z_2の定義
                                d2(27, 2) = -1;
                                d2(28, 2) = 1;
                                d2(29, 2) = -1;
                                d2(30, 2) = 1;

                                % z_3の定義
                                d2(31, 3) = -1;
                                d2(32, 3) = 1;
                                d2(33, 3) = -1;
                                d2(34, 3) = 1;

                            elseif vehicle.leader_flag == 3
                                % d2行列を初期化
                                d2 = zeros(56, 5);

                                % z_1の定義
                                d2(37, 1) = -1;
                                d2(38, 1) = 1;
                                d2(39, 1) = -1;
                                d2(40, 1) = 1;

                                % z_2の定義
                                d2(41, 2) = -1;
                                d2(42, 2) = 1;
                                d2(43, 2) = -1;
                                d2(44, 2) = 1;

                                % z_3の定義
                                d2(45, 3) = -1;
                                d2(46, 3) = 1;
                                d2(47, 3) = -1;
                                d2(48, 3) = 1;

                                % z_4の定義
                                d2(49, 4) = -1;
                                d2(50, 4) = 1;
                                d2(51, 4) = -1;
                                d2(52, 4) = 1;

                                % z_5の定義
                                d2(53, 5) = -1;
                                d2(54, 5) = 1;
                                d2(55, 5) = -1;
                                d2(56, 5) = 1;

                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_D2行列にd2をプッシュ
                            tmp_D2 = blkdiag(tmp_D2, d2);
                        end
                    else
                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % d2行列を初期化
                                d2 = zeros(18, 1);

                                % z_1の定義
                                d2(15, 1) = -1;
                                d2(16, 1) = 1;
                                d2(17, 1) = -1;
                                d2(18, 1) = 1;

                            elseif vehicle.leader_flag == 3
                                % d2行列を初期化
                                d2 = zeros(39, 3);

                                % z_1の定義
                                d2(28, 1) = -1;
                                d2(29, 1) = 1;
                                d2(30, 1) = -1;
                                d2(31, 1) = 1;

                                % z_2の定義
                                d2(32, 2) = -1;
                                d2(33, 2) = 1;
                                d2(34, 2) = -1;
                                d2(35, 2) = 1;

                                % z_3の定義
                                d2(36, 3) = -1;
                                d2(37, 3) = 1;
                                d2(38, 3) = -1;
                                d2(39, 3) = 1;

                            else
                                error('leader_flag is invalid.');
                            end

                            % tmp_D2行列にd2をプッシュ
                            tmp_D2 = blkdiag(tmp_D2, d2);
                        end
                    end

                    % D2行列にプッシュ
                    D2 = blkdiag(D2, tmp_D2);
                end
            end
        end

        % D2行列をプッシュ
        obj.MLDsMap('D2') = D2;

    elseif strcmp(property_name, 'D3')
        % D3行列を初期化
        D3 = [];

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数を取得
            num_lanes = LanePrmMap.Count();

            % delta_t_tableを取得
            delta_t_table = obj.RoadDeltaTMap(road_id);

            % 車線数で場合分け
            if num_lanes == 1
                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % tmp_D3行列を初期化
                tmp_D3 = [];

                % プロパティを取得
                dt = obj.dt;
                N_p = obj.N_p;

                % 法定速度を取得
                v = lane_prm.main.v;

                % 位置の最大値と最小値を取得
                if isempty(vehicles)
                    p_max = 0;
                    p_min = 0;
                else
                    p_max = vehicles(1, :).pos + dt * N_p * v;
                    p_min = vehicles(end, :).pos;
                end

                % 分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        %  レコードを取得
                        vehicle = vehicles(record_id, :);

                        % branch_flagによって場合分け
                        if branch_flag == 1
                            % 必要なパラメータを取得
                            h_d_min = lane_prm.main.h_d(p_max);
                            h_d_max = lane_prm.main.h_d(p_min);
                            h_p_min = lane_prm.main.h_p(p_min);
                            h_p_max = lane_prm.main.h_p(p_max);
                            h_f_min = lane_prm.main.h_f(p_max, p_min);
                            h_f_max = lane_prm.main.h_f(p_min, p_max);
                            h_b_min = lane_prm.main.h_b(p_max);
                            h_b_max = lane_prm.main.h_b(p_min);
                            h_o_min = lane_prm.main.h_o(p_max);
                            h_o_max = lane_prm.main.h_o(p_min);

                        elseif branch_flag == 2
                            % 必要なパラメータを取得
                            h_d_min = lane_prm.branch.right.h_d(p_max);
                            h_d_max = lane_prm.branch.right.h_d(p_min);
                            h_p_min = lane_prm.branch.right.h_p(p_min);
                            h_p_max = lane_prm.branch.right.h_p(p_max);
                            h_f_min = lane_prm.branch.right.h_f(p_max, p_min);
                            h_f_max = lane_prm.branch.right.h_f(p_min, p_max);
                            h_b_min = lane_prm.branch.right.h_b(p_max);
                            h_b_max = lane_prm.branch.right.h_b(p_min);
                            h_o_min = lane_prm.branch.right.h_o(p_max);
                            h_o_max = lane_prm.branch.right.h_o(p_min);

                        elseif branch_flag == 3
                            % 必要なパラメータを取得
                            h_d_min = lane_prm.branch.left.h_d(p_max);
                            h_d_max = lane_prm.branch.left.h_d(p_min);
                            h_p_min = lane_prm.branch.left.h_p(p_min);
                            h_p_max = lane_prm.branch.left.h_p(p_max);
                            h_f_min = lane_prm.branch.left.h_f(p_max, p_min);
                            h_f_max = lane_prm.branch.left.h_f(p_min, p_max);
                            h_b_min = lane_prm.branch.left.h_b(p_max);
                            h_b_max = lane_prm.branch.left.h_b(p_min);
                            h_o_min = lane_prm.branch.left.h_o(p_max);
                            h_o_max = lane_prm.branch.left.h_o(p_min);

                        else
                            error('branch_flag is invalid.');
                        end

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % d3行列を初期化
                            d3 = zeros(18, 6);

                            % delta_1の定義
                            d3(1, [1, 2, 4]) = [-1, -1, -1];
                            d3(2, [1, 2, 4]) = [0, 0, 1];
                            d3(3, [1, 2, 4]) = [1, 0, 1];
                            d3(4, [1, 2, 4]) = [0, 1, 1];

                            % delta_t1の定義
                            d3(5, [2, 3, 5]) = [-1, -1, -1];
                            d3(6, [2, 3, 5]) = [0, 0, 1];
                            d3(7, [2, 3, 5]) = [1, 0, 1];
                            d3(8, [2, 3, 5]) = [0, 1, 1];
                            
                            % delta_dの定義
                            d3(9, 1) = -h_d_min;
                            d3(10, 1) = -h_d_max;

                            % delta_pの定義
                            d3(11, 2) = -h_p_min;
                            d3(12, 2) = -h_p_max;

                            % delta_oの定義
                            d3(13, 3) = -h_o_min;
                            d3(14, 3) = -h_o_max;

                            % z_1の定義
                            d(15, 4) = p_min;
                            d(16, 4) = -p_max;
                            d(17, 4) = p_max;
                            d(18, 4) = -p_min;

                        elseif vehicle.leader_flag == 2
                            % d3行列を初期化
                            d3 = zeros(34, 9);

                            % delta_1の定義
                            d3(1, [1, 2, 6]) = [-1, -1, -1];
                            d3(2, [1, 2, 6]) = [0, 0, 1];
                            d3(3, [1, 2, 6]) = [1, 0, 1];
                            d3(4, [1, 2, 6]) = [0, 1, 1];

                            % delta_2の定義
                            d3(5, [3, 4, 6, 7]) = [1, 1, -1, -1];
                            d3(6, [3, 4, 6, 7]) = [-1, 0, 0, 1];
                            d3(7, [3, 4, 6, 7]) = [0, -1, 0, 1];
                            d3(8, [3, 4, 6, 7]) = [0, 0, 1, 1];

                            % delta_t1の定義
                            d3(9, [2, 5, 8]) = [-1, -1, -1];
                            d3(10, [2, 5, 8]) = [0, 0, 1];
                            d3(11, [2, 5, 8]) = [1, 0, 1];
                            d3(12, [2, 5, 8]) = [0, 1, 1];

                            % delta_dの定義
                            d3(13, 1) = -h_d_min;
                            d3(14, 1) = -h_d_max;

                            % delta_pの定義
                            d3(15, 2) = -h_p_min;
                            d3(16, 2) = -h_p_max;

                            % delta_f2の定義
                            d3(17, 3) = -h_f_min;
                            d3(18, 3) = -h_f_max;

                            % delta_bの定義
                            d3(19, 4) = -h_b_min;
                            d3(20, 4) = -h_b_max;

                            % delta_oの定義
                            d3(21, 5) = -h_o_min;
                            d3(22, 5) = -h_o_max;

                            % z_1の定義
                            d3(23, 6) = p_min;
                            d3(24, 6) = -p_max;
                            d3(25, 6) = p_max;
                            d3(26, 6) = -p_min;

                            % z_2の定義
                            d3(27, 7) = p_min;
                            d3(28, 7) = -p_max;
                            d3(29, 7) = p_max;
                            d3(30, 7) = -p_min;

                            % z_3の定義
                            d3(31, 7) = p_min;
                            d3(32, 7) = -p_max;
                            d3(33, 7) = p_max;
                            d3(34, 7) = -p_min;

                        elseif vehicle.leader_flag == 3
                            % d3行列を初期化
                            d3 = zeros(56, 13);

                            % delta_1の定義
                            d3(1, [1, 2, 7]) = [-1, -1, -1];
                            d3(2, [1, 2, 7]) = [0, 0, 1];
                            d3(3, [1, 2, 7]) = [1, 0, 1];
                            d3(4, [1, 2, 7]) = [0, 1, 1];

                            % delta_2の定義
                            d3(5, [3, 5, 7, 8]) = [1, 1, -1, -1];
                            d3(6, [3, 5, 7, 8]) = [-1, 0, 0, 1];
                            d3(7, [3, 5, 7, 8]) = [0, -1, 0, 1];
                            d3(8, [3, 5, 7, 8]) = [0, 0, 1, 1];

                            % delta_3の定義
                            d3(9, [4, 5, 7, 9]) = [1, -1, -1, -1];
                            d3(10, [4, 5, 7, 9]) = [-1, 0, 0, 1];
                            d3(11, [4, 5, 7, 9]) = [0, 1, 0, 1];
                            d3(12, [4, 5, 7, 9]) = [0, 0, 1, 1];

                            % delta_t1の定義
                            d3(13, [2, 6, 10]) = [-1, -1, -1];
                            d3(14, [2, 6, 10]) = [0, 0, 1];
                            d3(15, [2, 6, 10]) = [1, 0, 1];
                            d3(16, [2, 6, 10]) = [0, 1, 1];

                            % delta_t2の定義（あとでdelta_t(j)の情報追加）
                            d3(17, [2, 6, 11]) = [-1, -1, -1];
                            d3(18, [2, 6, 11]) = [0, 0, 1];
                            d3(19, [2, 6, 11]) = [0, 0, 1];
                            d3(20, [2, 6, 11]) = [1, 0, 1];
                            d3(21, [2, 6, 11]) = [0, 1, 1];
                            
                            % delta_t3の定義
                            d3(22, [10, 11, 12]) = [1, 1, -1];
                            d3(23, [10, 11, 12]) = [-1, 0, 1];
                            d3(24, [10, 11, 12]) = [0, -1, 1];

                            % delta_dの定義
                            d3(25, 1) = -h_d_min;
                            d3(26, 1) = -h_d_max;

                            % delta_pの定義
                            d3(27, 2) = -h_p_min;
                            d3(28, 2) = -h_p_max;

                            % delta_f2の定義
                            d3(29, 3) = -h_f_min;
                            d3(30, 3) = -h_f_max;

                            % delta_f3の定義
                            d3(31, 4) = -h_f_min;
                            d3(32, 4) = -h_f_max;

                            % delta_bの定義
                            d3(33, 5) = -h_b_min;
                            d3(34, 5) = -h_b_max;

                            % delta_oの定義
                            d3(35, 6) = -h_o_min;
                            d3(36, 6) = -h_o_max;

                            % z_1の定義
                            d3(37, 7) = p_min;
                            d3(38, 7) = -p_max;
                            d3(39, 7) = p_max;
                            d3(40, 7) = -p_min; 

                            % z_2の定義
                            d3(41, 8) = p_min;
                            d3(42, 8) = -p_max;
                            d3(43, 8) = p_max;
                            d3(44, 8) = -p_min;

                            % z_3の定義
                            d3(45, 8) = p_min;
                            d3(46, 8) = -p_max;
                            d3(47, 8) = p_max;
                            d3(48, 8) = -p_min;

                            % z_4の定義
                            d3(49, 9) = p_min;
                            d3(50, 9) = -p_max;
                            d3(51, 9) = p_max;
                            d3(52, 9) = -p_min;

                            % z_5の定義
                            d3(53, 9) = p_min;
                            d3(54, 9) = -p_max;
                            d3(55, 9) = p_max;
                            d3(56, 9) = -p_min;
                        else
                            error('leader_flag is invalid.');
                        end

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 3
                            % tmp_D3の行数を取得
                            num_rows = size(tmp_D3, 1);

                            % tmp_D3行列にd3をプッシュ
                            tmp_D3 = blkdiag(tmp_D3, d3);

                            % delta_tの変数の場所を取得
                            delta_t_row_id = delta_t_table(record_id, :).delta_t;

                            % delta_tの情報を追加
                            tmp_D3(num_rows + 17, delta_t_row_id) = 1;
                            tmp_D3(num_rows + 18, delta_t_row_id) = -1;
                        else
                            % tmp_D3行列にd3をプッシュ
                            tmp_D3 = blkdiag(tmp_D3, d3);
                        end
                    end
                else
                    % 必要なパラメータを取得
                    h_d_min = lane_prm.main.h_d(p_max);
                    h_d_max = lane_prm.main.h_d(p_min);
                    h_p_min = lane_prm.main.h_p(p_min);
                    h_p_max = lane_prm.main.h_p(p_max);
                    h_f_min = lane_prm.main.h_f(p_max, p_min);
                    h_f_max = lane_prm.main.h_f(p_min, p_max);
                    h_o_min = lane_prm.main.h_o(p_max);
                    h_o_max = lane_prm.main.h_o(p_min);

                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % d3行列を初期化
                            d3 = zeros(18, 6);

                            % delta_1の定義
                            d3(1, [1, 2, 4]) = [-1, -1, -1];
                            d3(2, [1, 2, 4]) = [0, 0, 1];
                            d3(3, [1, 2, 4]) = [1, 0, 1];
                            d3(4, [1, 2, 4]) = [0, 1, 1];

                            % delta_t1の定義
                            d3(5, [2, 3, 5]) = [-1, -1, -1];
                            d3(6, [2, 3, 5]) = [0, 0, 1];
                            d3(7, [2, 3, 5]) = [1, 0, 1];
                            d3(8, [2, 3, 5]) = [0, 1, 1];

                            % delta_dの定義
                            d3(9, 1) = -h_d_min;
                            d3(10, 1) = -h_d_max;

                            % delta_pの定義
                            d3(11, 2) = -h_p_min;
                            d3(12, 2) = -h_p_max;

                            % delta_oの定義
                            d3(13, 3) = -h_o_min;
                            d3(14, 3) = -h_o_max;

                            % z_1の定義
                            d3(15, 4) = p_min;
                            d3(16, 4) = -p_max;
                            d3(17, 4) = p_max;
                            d3(18, 4) = -p_min;
    
                        elseif vehicle.leader_flag == 3
                            % d3行列を初期化
                            d3 = zeros(39, 10);

                            % delta_1の定義
                            d3(1, [1, 2, 5]) = [-1, -1, -1];
                            d3(2, [1, 2, 5]) = [0, 0, 1];
                            d3(3, [1, 2, 5]) = [1, 0, 1];
                            d3(4, [1, 2, 5]) = [0, 1, 1];

                            % delta_2の定義
                            d3(5, [3, 5, 6]) = [1, -1, -1];
                            d3(6, [3, 5, 6]) = [-1, 0, 1];
                            d3(7, [3, 5, 6]) = [0, 1, 1];

                            % delta_t1の定義
                            d3(8, [2, 4, 7]) = [-1, -1, -1];
                            d3(9, [2, 4, 7]) = [0, 0, 1];
                            d3(10, [2, 4, 7]) = [1, 0, 1];
                            d3(11, [2, 4, 7]) = [0, 1, 1];

                            % delta_t2の定義
                            d3(12, [2, 4, 8]) = [-1, -1, -1];
                            d3(13, [2, 4, 8]) = [0, 0, 1];
                            d3(14, [2, 4, 8]) = [0, 0, 1];
                            d3(15, [2, 4, 8]) = [1, 0, 1];
                            d3(16, [2, 4, 8]) = [0, 1, 1];

                            % delta_t3の定義
                            d3(17, [7, 8, 9]) = [1, 1, -1];
                            d3(18, [7, 8, 9]) = [-1, 0, 1];
                            d3(19, [7, 8, 9]) = [0, -1, 1];

                            % delta_dの定義
                            d3(20, 1) = -h_d_min;
                            d3(21, 1) = -h_d_max;

                            % delta_pの定義
                            d3(22, 2) = -h_p_min;
                            d3(23, 2) = -h_p_max;

                            % delta_f1の定義
                            d3(24, 3) = -h_f_min;
                            d3(25, 3) = -h_f_max;

                            % delta_oの定義
                            d3(26, 4) = -h_o_min;
                            d3(27, 4) = -h_o_max;

                            % z_1の定義
                            d3(28, 5) = p_min;
                            d3(29, 5) = -p_max;
                            d3(30, 5) = p_max;
                            d3(31, 5) = -p_min;

                            % z_2の定義
                            d3(32, 6) = p_min;
                            d3(33, 6) = -p_max;
                            d3(34, 6) = p_max;
                            d3(35, 6) = -p_min;

                            % z_3の定義
                            d3(36, 6) = p_min;
                            d3(37, 6) = -p_max;
                            d3(38, 6) = p_max;
                            d3(39, 6) = -p_min;

                        else
                            error('leader_flag is invalid.');
                        end

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 3
                            % tmp_D3の行数を取得
                            num_rows = size(tmp_D3, 1);

                            % tmp_D3行列にd3をプッシュ
                            tmp_D3 = blkdiag(tmp_D3, d3);

                            % delta_tの変数の場所を取得
                            delta_t_row_id = delta_t_table(record_id, :).delta_t;

                            % delta_tの情報を追加
                            tmp_D3(num_rows + 12, delta_t_row_id) = 1;
                            tmp_D3(num_rows + 13, delta_t_row_id) = -1;
                        else
                            % tmp_D3行列にd3をプッシュ
                            tmp_D3 = blkdiag(tmp_D3, d3);
                        end
                    end
                end

                % D3行列にプッシュ
                D3 = blkdiag(D3, tmp_D3);
            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % lane_prmを取得
                    lane_prm = LanePrmMap(lane_id);

                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % その車線のdelta_t_tableを取得
                    tmp_delta_t_table = delta_t_table(delta_t_table.stop_lane == lane_id, :);

                    % tmp_D3行列を初期化
                    tmp_D3 = [];

                    % プロパティを取得
                    dt = obj.dt;
                    N_p = obj.N_p;

                    % 法定速度を取得
                    v = lane_prm.main.v;

                    % 位置の最大値と最小値を取得
                    if isempty(tmp_vehicles)
                        p_max = dt * N_p * v;
                        p_min = 0;
                    else
                        p_max = tmp_vehicles(1, :).pos + dt * N_p * v;
                        p_min = tmp_vehicles(end, :).pos;
                    end

                    % 分岐があるかどうかで場合分け
                    if isfield(lane_prm, 'branch')
                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % branch_flagによって場合分け
                            if vehicle.branch_flag == 1
                                % 必要なパラメータを取得
                                h_d_min = lane_prm.main.h_d(p_max);
                                h_d_max = lane_prm.main.h_d(p_min);
                                h_p_min = lane_prm.main.h_p(p_min);
                                h_p_max = lane_prm.main.h_p(p_max);
                                h_f_min = lane_prm.main.h_f(p_max, p_min);
                                h_f_max = lane_prm.main.h_f(p_min, p_max);
                                h_b_min = lane_prm.main.h_b(p_max);
                                h_b_max = lane_prm.main.h_b(p_min);
                                h_o_min = lane_prm.main.h_o(p_max);
                                h_o_max = lane_prm.main.h_o(p_min);

                            elseif vehicle.branch_flag == 2 || vehicle.branch_flag == 3
                                % 必要なパラメータを取得
                                h_d_min = lane_prm.branch.h_d(p_max);
                                h_d_max = lane_prm.branch.h_d(p_min);
                                h_p_min = lane_prm.branch.h_p(p_min);
                                h_p_max = lane_prm.branch.h_p(p_max);
                                h_f_min = lane_prm.branch.h_f(p_max, p_min);
                                h_f_max = lane_prm.branch.h_f(p_min, p_max);
                                h_b_min = lane_prm.branch.h_b(p_max);
                                h_b_max = lane_prm.branch.h_b(p_min);
                                h_o_min = lane_prm.branch.h_o(p_max);
                                h_o_max = lane_prm.branch.h_o(p_min);

                            else
                                error('branch_flag is invalid.');
                            end

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % d3行列を初期化
                                d3 = zeros(18, 6);

                                % delta_1の定義
                                d3(1, [1, 2, 4]) = [-1, -1, -1];
                                d3(2, [1, 2, 4]) = [0, 0, 1];
                                d3(3, [1, 2, 4]) = [1, 0, 1];
                                d3(4, [1, 2, 4]) = [0, 1, 1];

                                % delta_t1の定義
                                d3(5, [2, 3, 5]) = [-1, -1, -1];
                                d3(6, [2, 3, 5]) = [0, 0, 1];
                                d3(7, [2, 3, 5]) = [1, 0, 1];
                                d3(8, [2, 3, 5]) = [0, 1, 1];

                                % delta_dの定義
                                d3(9, 1) = -h_d_min;
                                d3(10, 1) = -h_d_max;

                                % delta_pの定義
                                d3(11, 2) = -h_p_min;
                                d3(12, 2) = -h_p_max;

                                % delta_oの定義
                                d3(13, 3) = -h_o_min;
                                d3(14, 3) = -h_o_max;

                                % z_1の定義
                                d3(15, 4) = p_min;
                                d3(16, 4) = -p_max;
                                d3(17, 4) = p_max;
                                d3(18, 4) = -p_min;

                            elseif vehicle.leader_flag == 2
                                % d3行列を初期化
                                d3 = zeros(34, 9);

                                % delta_1の定義
                                d3(1, [1, 2, 6]) = [-1, -1, -1];
                                d3(2, [1, 2, 6]) = [0, 0, 1];
                                d3(3, [1, 2, 6]) = [1, 0, 1];
                                d3(4, [1, 2, 6]) = [0, 1, 1];

                                % delta_2の定義
                                d3(5, [3, 4, 6, 7]) = [1, 1, -1, -1];
                                d3(6, [3, 4, 6, 7]) = [-1, 0, 0, 1];
                                d3(7, [3, 4, 6, 7]) = [0, -1, 0, 1];
                                d3(8, [3, 4, 6, 7]) = [0, 0, 1, 1];

                                % delta_t1の定義
                                d3(9, [2, 5, 8]) = [-1, -1, -1];
                                d3(10, [2, 5, 8]) = [0, 0, 1];
                                d3(11, [2, 5, 8]) = [1, 0, 1];
                                d3(12, [2, 5, 8]) = [0, 1, 1];

                                % delta_dの定義
                                d3(13, 1) = -h_d_min;
                                d3(14, 1) = -h_d_max;
                                
                                % delta_pの定義
                                d3(15, 2) = -h_p_min;
                                d3(16, 2) = -h_p_max;

                                % delta_f2の定義
                                d3(17, 3) = -h_f_min;
                                d3(18, 3) = -h_f_max;

                                % delta_bの定義
                                d3(19, 4) = -h_b_min;
                                d3(20, 4) = -h_b_max;

                                % delta_oの定義
                                d3(21, 5) = -h_o_min;
                                d3(22, 5) = -h_o_max;

                                % z_1の定義
                                d3(23, 6) = p_min;
                                d3(24, 6) = -p_max;
                                d3(25, 6) = p_max;
                                d3(26, 6) = -p_min;

                                % z_2の定義
                                d3(27, 7) = p_min;
                                d3(28, 7) = -p_max;
                                d3(29, 7) = p_max;
                                d3(30, 7) = -p_min;

                                % z_3の定義
                                d3(31, 7) = p_min;
                                d3(32, 7) = -p_max;
                                d3(33, 7) = p_max;
                                d3(34, 7) = -p_min;

                            elseif vehicle.leader_flag == 3
                                % d3行列を初期化
                                d3 = zeros(56, 13);

                                % delta_1の定義
                                d3(1, [1, 2, 7]) = [-1, -1, -1];
                                d3(2, [1, 2, 7]) = [0, 0, 1];
                                d3(3, [1, 2, 7]) = [1, 0, 1];
                                d3(4, [1, 2, 7]) = [0, 1, 1];

                                % delta_2の定義
                                d3(5, [3, 5, 7, 8]) = [1, 1, -1, -1];
                                d3(6, [3, 5, 7, 8]) = [-1, 0, 0, 1];
                                d3(7, [3, 5, 7, 8]) = [0, -1, 0, 1];
                                d3(8, [3, 5, 7, 8]) = [0, 0, 1, 1];

                                % delta_3の定義
                                d3(9, [4, 5, 7, 9]) = [1, -1, -1, -1];
                                d3(10, [4, 5, 7, 9]) = [-1, 0, 0, 1];
                                d3(11, [4, 5, 7, 9]) = [0, 1, 0, 1];
                                d3(12, [4, 5, 7, 9]) = [0, 0, 1, 1];

                                % delta_t1の定義
                                d3(13, [2, 6, 10]) = [-1, -1, -1];
                                d3(14, [2, 6, 10]) = [0, 0, 1];
                                d3(15, [2, 6, 10]) = [1, 0, 1];
                                d3(16, [2, 6, 10]) = [0, 1, 1];

                                % delta_t2の定義
                                d3(17, [2, 6, 11]) = [-1, -1, -1];  
                                d3(18, [2, 6, 11]) = [0, 0, 1];
                                d3(19, [2, 6, 11]) = [0, 0, 1];
                                d3(20, [2, 6, 11]) = [1, 0, 1];
                                d3(21, [2, 6, 11]) = [0, 1, 1];

                                % delta_t3の定義
                                d3(22, [10, 11, 12]) = [1, 1, -1];
                                d3(23, [10, 11, 12]) = [-1, 0, 1];
                                d3(24, [10, 11, 12]) = [0, -1, 1];

                                % delta_dの定義
                                d3(25, 1) = -h_d_min;
                                d3(26, 1) = -h_d_max;

                                % delta_pの定義
                                d3(27, 2) = -h_p_min;
                                d3(28, 2) = -h_p_max;

                                % delta_f2の定義
                                d3(29, 3) = -h_f_min;
                                d3(30, 3) = -h_f_max;

                                % delta_f3の定義
                                d3(31, 4) = -h_f_min;
                                d3(32, 4) = -h_f_max;

                                % delta_bの定義
                                d3(33, 5) = -h_b_min;
                                d3(34, 5) = -h_b_max;

                                % delta_oの定義
                                d3(35, 6) = -h_o_min;
                                d3(36, 6) = -h_o_max;

                                % z_1の定義
                                d3(37, 7) = p_min;
                                d3(38, 7) = -p_max;
                                d3(39, 7) = p_max;
                                d3(40, 7) = -p_min;

                                % z_2の定義
                                d3(41, 8) = p_min;
                                d3(42, 8) = -p_max;
                                d3(43, 8) = p_max;
                                d3(44, 8) = -p_min;

                                % z_3の定義
                                d3(45, 8) = p_min;
                                d3(46, 8) = -p_max;
                                d3(47, 8) = p_max;
                                d3(48, 8) = -p_min;

                                % z_4の定義
                                d3(49, 9) = p_min;
                                d3(50, 9) = -p_max;
                                d3(51, 9) = p_max;
                                d3(52, 9) = -p_min;

                                % z_5の定義
                                d3(53, 9) = p_min;
                                d3(54, 9) = -p_max;
                                d3(55, 9) = p_max;
                                d3(56, 9) = -p_min;

                            else
                                error('leader_flag is invalid.');
                            end
                            
                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 3
                                % tmp_D3の行数を取得
                                num_rows = size(tmp_D3, 1);

                                % tmp_D3行列にd3をプッシュ
                                tmp_D3 = blkdiag(tmp_D3, d3);

                                % delta_tの変数の場所を取得
                                delta_t_row_id = tmp_delta_t_table(record_id, :).delta_t;

                                % delta_tの情報を追加
                                tmp_D3(num_rows + 17, delta_t_row_id) = 1;
                                tmp_D3(num_rows + 18, delta_t_row_id) = -1;
                            else
                                % tmp_D3行列にd3をプッシュ
                                tmp_D3 = blkdiag(tmp_D3, d3);
                            end
                        end
                    else
                        % 必要なパラメータを取得
                        h_d_min = lane_prm.main.h_d(p_max);
                        h_d_max = lane_prm.main.h_d(p_min);
                        h_p_min = lane_prm.main.h_p(p_min);
                        h_p_max = lane_prm.main.h_p(p_max);
                        h_f_min = lane_prm.main.h_f(p_max, p_min);
                        h_f_max = lane_prm.main.h_f(p_min, p_max);
                        h_o_min = lane_prm.main.h_o(p_max);
                        h_o_max = lane_prm.main.h_o(p_min);

                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % d3行列を初期化
                                d3 = zeros(18, 6);

                                % delta_1の定義
                                d3(1, [1, 2, 4]) = [-1, -1, -1];
                                d3(2, [1, 2, 4]) = [0, 0, 1];
                                d3(3, [1, 2, 4]) = [1, 0, 1];
                                d3(4, [1, 2, 4]) = [0, 1, 1];

                                % delta_t1の定義
                                d3(5, [2, 3, 5]) = [-1, -1, -1];
                                d3(6, [2, 3, 5]) = [0, 0, 1];
                                d3(7, [2, 3, 5]) = [1, 0, 1];
                                d3(8, [2, 3, 5]) = [0, 1, 1];

                                % delta_dの定義
                                d3(9, 1) = -h_d_min;
                                d3(10, 1) = -h_d_max;

                                % delta_pの定義
                                d3(11, 2) = -h_p_min;
                                d3(12, 2) = -h_p_max;

                                % delta_oの定義
                                d3(13, 3) = -h_o_min;
                                d3(14, 3) = -h_o_max;

                                % z_1の定義
                                d3(15, 4) = p_min;
                                d3(16, 4) = -p_max;
                                d3(17, 4) = p_max;
                                d3(18, 4) = -p_min;

                            elseif vehicle.leader_flag == 3
                                % d3行列を初期化
                                d3 = zeros(39, 10);

                                % delta_1の定義
                                d3(1, [1, 2, 5]) = [-1, -1, -1];
                                d3(2, [1, 2, 5]) = [0, 0, 1];
                                d3(3, [1, 2, 5]) = [1, 0, 1];
                                d3(4, [1, 2, 5]) = [0, 1, 1];

                                % delta_2の定義
                                d3(5, [3, 5, 6]) = [1, -1, -1];
                                d3(6, [3, 5, 6]) = [-1, 0, 1];
                                d3(7, [3, 5, 6]) = [0, 1, 1];

                                % delta_t1の定義
                                d3(8, [2, 4, 7]) = [-1, -1, -1];
                                d3(9, [2, 4, 7]) = [0, 0, 1];
                                d3(10, [2, 4, 7]) = [1, 0, 1];
                                d3(11, [2, 4, 7]) = [0, 1, 1];

                                % delta_t2の定義
                                d3(12, [2, 4, 8]) = [-1, -1, -1];
                                d3(13, [2, 4, 8]) = [0, 0, 1];
                                d3(14, [2, 4, 8]) = [0, 0, 1];
                                d3(15, [2, 4, 8]) = [1, 0, 1];
                                d3(16, [2, 4, 8]) = [0, 1, 1];

                                % delta_t3の定義
                                d3(17, [7, 8, 9]) = [1, 1, -1];
                                d3(18, [7, 8, 9]) = [-1, 0, 1];
                                d3(19, [7, 8, 9]) = [0, -1, 1];

                                % delta_dの定義
                                d3(20, 1) = -h_d_min;
                                d3(21, 1) = -h_d_max;

                                % delta_pの定義
                                d3(22, 2) = -h_p_min;
                                d3(23, 2) = -h_p_max;

                                % delta_f1の定義
                                d3(24, 3) = -h_f_min;
                                d3(25, 3) = -h_f_max;

                                % delta_oの定義
                                d3(26, 4) = -h_o_min;
                                d3(27, 4) = -h_o_max;

                                % z_1の定義
                                d3(28, 5) = p_min;
                                d3(29, 5) = -p_max;
                                d3(30, 5) = p_max;
                                d3(31, 5) = -p_min;

                                % z_2の定義
                                d3(32, 6) = p_min;
                                d3(33, 6) = -p_max;
                                d3(34, 6) = p_max;
                                d3(35, 6) = -p_min;

                                % z_3の定義
                                d3(36, 6) = p_min;
                                d3(37, 6) = -p_max;
                                d3(38, 6) = p_max;
                                d3(39, 6) = -p_min;

                            else
                                error('leader_flag is invalid.');
                            end

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 3
                                % tmp_D3の行数を取得
                                num_rows = size(tmp_D3, 1);

                                % tmp_D3行列にd3をプッシュ
                                tmp_D3 = blkdiag(tmp_D3, d3);

                                % delta_tの変数の場所を取得
                                delta_t_row_id = tmp_delta_t_table(record_id, :).delta_t;

                                % delta_tの情報を追加
                                tmp_D3(num_rows + 12, delta_t_row_id) = 1;
                                tmp_D3(num_rows + 13, delta_t_row_id) = -1;
                            else
                                % tmp_D3行列にd3をプッシュ
                                tmp_D3 = blkdiag(tmp_D3, d3);
                            end
                        end
                    end

                    % D3行列にプッシュ
                    D3 = blkdiag(D3, tmp_D3);
                end
            end
        end

        % D3行列をプッシュ
        obj.MLDsMap('D3') = D3;

    elseif strcmp(property_name, 'E')
        % E行列を初期化
        E = [];

        % 道路を走査
        for road_id = 1:obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数を取得
            num_lanes = LanePrmMap.Count();

            % 車線数で場合分け
            if num_lanes == 1
                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % tmp_E行列を初期化
                tmp_E = [];

                % プロパティを取得
                dt = obj.dt;
                N_p = obj.N_p;

                % 法定速度を取得
                v = lane_prm.main.v;

                % 位置の最大値と最小値を取得
                if isempty(vehicles)
                    p_max = dt * N_p * v;
                    p_min = 0;
                else
                    p_max = vehicles(1, :).pos + dt * N_p * v;
                    p_min = vehicles(end, :).pos;
                end
                
                % 分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % branch_flagによって場合分け
                        if vehicle.branch_flag == 1
                            % 必要なパラメータを取得
                            p_s = lane_prm.main.p_s;
                            D_s = lane_prm.main.D_s;
                            d_s = lane_prm.main.d_s;
                            D_f = lane_prm.main.D_f;
                            D_b = lane_prm.main.D_b;
                            D_o = lane_prm.main.D_o;
                            h_d_min = lane_prm.main.h_d(p_max);
                            h_p_min = lane_prm.main.h_p(p_min);
                            h_f_min = lane_prm.main.h_f(p_max, p_min);
                            h_b_min = lane_prm.main.h_b(p_max);
                            h_o_min = lane_prm.main.h_o(p_max);

                        elseif vehicle.branch_flag == 2
                            % 必要なパラメータを取得
                            p_s = lane_prm.branch.right.p_s;
                            D_s = lane_prm.branch.right.D_s;
                            d_s = lane_prm.branch.right.d_s;
                            D_f = lane_prm.branch.right.D_f;
                            D_b = lane_prm.branch.right.D_b;
                            D_o = lane_prm.branch.right.D_o;
                            h_d_min = lane_prm.branch.right.h_d(p_max);
                            h_p_min = lane_prm.branch.right.h_p(p_min);
                            h_f_min = lane_prm.branch.right.h_f(p_max, p_min);
                            h_b_min = lane_prm.branch.right.h_b(p_max);
                            h_o_min = lane_prm.branch.right.h_o(p_max);

                        elseif vehicle.branch_flag == 3
                            % 必要なパラメータを取得
                            p_s = lane_prm.branch.left.p_s;
                            D_s = lane_prm.branch.left.D_s;
                            d_s = lane_prm.branch.left.d_s;
                            D_f = lane_prm.branch.left.D_f;
                            D_b = lane_prm.branch.left.D_b;
                            D_o = lane_prm.branch.left.D_o;
                            h_d_min = lane_prm.branch.left.h_d(p_max);
                            h_p_min = lane_prm.branch.left.h_p(p_min);
                            h_f_min = lane_prm.branch.left.h_f(p_max, p_min);
                            h_b_min = lane_prm.branch.left.h_b(p_max);
                            h_o_min = lane_prm.branch.left.h_o(p_max);

                        else
                            error('branch_flag is invalid.');
                        end

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % e行列を初期化
                            e = zeros(18, 1);

                            % delta_1の定義
                            e(1) = -1;
                            e(2) = 1;
                            e(3) = 1;
                            e(4) = 1;

                            % delta_t1の定義
                            e(5) = -1;
                            e(6) = 1;
                            e(7) = 1;
                            e(8) = 1;

                            % delta_dの定義
                            e(9) = p_s - D_s - h_d_min;
                            e(10) = -p_s + D_s;

                            % delta_pの定義
                            e(11) = -p_s + d_s - h_p_min;
                            e(12) = p_s - d_s;

                            % delta_oの定義
                            e(13) = p_s - D_o - h_o_min;
                            e(14) = -p_s + D_o;

                            % z_1の定義
                            e(15) = 0;
                            e(16) = 0;
                            e(17) = p_max;
                            e(18) = -p_min;

                        elseif vehicle.leader_flag == 2
                            % e行列を初期化
                            e = zeros(34, 1);

                            % delta_1の定義
                            e(1) = -1;
                            e(2) = 1;
                            e(3) = 1;
                            e(4) = 1;

                            % delta_2の定義
                            e(5) = 1;
                            e(6) = 0;
                            e(7) = 0;
                            e(8) = 1;

                            % delta_t1の定義
                            e(9) = -1;  
                            e(10) = 1;
                            e(11) = 1;
                            e(12) = 1;

                            % delta_dの定義
                            e(13) = p_s - D_s - h_d_min;
                            e(14) = -p_s + D_s;

                            % delta_pの定義
                            e(15) = -p_s + d_s - h_p_min;
                            e(16) = p_s - d_s;

                            % delta_f2の定義
                            e(17) = D_f - h_f_min;
                            e(18) = -D_f;

                            % delta_bの定義
                            e(19) = p_s - D_b - h_b_min;
                            e(20) = -p_s + D_b;

                            % delta_oの定義
                            e(21) = p_s - D_o - h_o_min;
                            e(22) = -p_s + D_o;

                            % z_1の定義
                            e(23) = 0;
                            e(24) = 0;
                            e(25) = p_max;
                            e(26) = -p_min;

                            % z_2の定義
                            e(27) = 0;
                            e(28) = 0;
                            e(29) = p_max;
                            e(30) = -p_min;

                            % z_3の定義
                            e(31) = 0;
                            e(32) = 0;
                            e(33) = p_max;
                            e(34) = -p_min;

                        elseif vehicle.leader_flag == 3
                            % e行列を初期化
                            e = zeros(56, 1);

                            % delta_1の定義
                            e(1) = -1;
                            e(2) = 1;
                            e(3) = 1;
                            e(4) = 1;

                            % delta_2の定義
                            e(5) = 1;
                            e(6) = 0;
                            e(7) = 0;
                            e(8) = 1;

                            % delta_3の定義
                            e(9) = 0;
                            e(10) = 0;
                            e(11) = 1;
                            e(12) = 1;

                            % delta_t1の定義
                            e(13) = -1;
                            e(14) = 1;
                            e(15) = 1;
                            e(16) = 1;

                            % delta_t2の定義
                            e(17) = 1;
                            e(18) = 0;
                            e(19) = 0;
                            e(20) = 1;
                            e(21) = 1;

                            % delta_t3の定義
                            e(22) = 1;
                            e(23) = 0;
                            e(24) = 0;

                            % delta_dの定義
                            e(25) = p_s - D_s - h_d_min;
                            e(26) = -p_s + D_s;

                            % delta_pの定義
                            e(27) = -p_s + d_s - h_p_min;
                            e(28) = p_s - d_s;

                            % delta_f2の定義
                            e(29) = D_f - h_f_min;
                            e(30) = -D_f;

                            % delta_f3の定義
                            e(31) = D_f - h_f_min;
                            e(32) = -D_f;

                            % delta_bの定義
                            e(33) = p_s - D_b - h_b_min;
                            e(34) = -p_s + D_b;

                            % delta_oの定義
                            e(35) = p_s - D_o - h_o_min;
                            e(36) = -p_s + D_o;

                            % z_1の定義
                            e(37) = 0;
                            e(38) = 0;
                            e(39) = p_max;
                            e(40) = -p_min;

                            % z_2の定義
                            e(41) = 0;
                            e(42) = 0;
                            e(43) = p_max;
                            e(44) = -p_min;

                            % z_3の定義
                            e(45) = 0;
                            e(46) = 0;
                            e(47) = p_max;
                            e(48) = -p_min;

                            % z_4の定義
                            e(49) = 0;
                            e(50) = 0;
                            e(51) = p_max;
                            e(52) = -p_min;

                            % z_5の定義
                            e(53) = 0;
                            e(54) = 0;
                            e(55) = p_max;
                            e(56) = -p_min;

                        else
                            error('leader_flag is invalid.');
                        end

                        % e行列をtmp_E行列にプッシュ
                        tmp_E = [tmp_E; e];
                    end
                else
                    % 必要なパラメータを取得
                    p_s = lane_prm.main.p_s;
                    D_s = lane_prm.main.D_s;
                    d_s = lane_prm.main.d_s;
                    D_f = lane_prm.main.D_f;
                    D_o = lane_prm.main.D_o;
                    h_d_min = lane_prm.main.h_d(p_max);
                    h_p_min = lane_prm.main.h_p(p_min);
                    h_f_min = lane_prm.main.h_f(p_max, p_min);
                    h_o_min = lane_prm.main.h_o(p_max);

                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                        % レコードを取得
                        vehicle = vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % e行列を初期化
                            e = zeros(18, 1);

                            % delta_1の定義
                            e(1) = -1;
                            e(2) = 1;
                            e(3) = 1;
                            e(4) = 1;

                            % delta_t1の定義
                            e(5) = -1;
                            e(6) = 1;
                            e(7) = 1;
                            e(8) = 1;

                            % delta_dの定義
                            e(9) = p_s - D_s - h_d_min;
                            e(10) = -p_s + D_s;

                            % delta_pの定義
                            e(11) = -p_s + d_s - h_p_min;
                            e(12) = p_s - d_s;

                            % delta_oの定義
                            e(13) = p_s - D_o - h_o_min;
                            e(14) = -p_s + D_o;

                            % z_1の定義
                            e(15) = 0;
                            e(16) = 0;
                            e(17) = p_max;
                            e(18) = -p_min;

                        elseif vehicle.leader_flag == 3
                            % e行列を初期化
                            e = zeros(39, 1);

                            % delta_1の定義
                            e(1) = -1;
                            e(2) = 1;
                            e(3) = 1;
                            e(4) = 1;

                            % delta_2の定義
                            e(5) = 0;
                            e(6) = 0;
                            e(7) = 1;

                            % delta_t1の定義
                            e(8) = -1;
                            e(9) = 1;
                            e(10) = 1;
                            e(11) = 1;

                            % delta_t2の定義
                            e(12) = 1;
                            e(13) = 0;
                            e(14) = 0;
                            e(15) = 1;
                            e(16) = 1;

                            % delta_t3の定義
                            e(17) = 1;
                            e(18) = 0;
                            e(19) = 0;

                            % delta_dの定義
                            e(20) = p_s - D_s - h_d_min;
                            e(21) = -p_s + D_s;

                            % delta_pの定義
                            e(22) = -p_s + d_s - h_p_min;
                            e(23) = p_s - d_s;

                            % delta_f1の定義
                            e(24) = D_f - h_f_min;
                            e(25) = -D_f;

                            % delta_oの定義
                            e(26) = p_s - D_o - h_o_min;
                            e(27) = -p_s + D_o;

                            % z_1の定義
                            e(28) = 0;
                            e(29) = 0;
                            e(30) = p_max;
                            e(31) = -p_min;

                            % z_2の定義
                            e(32) = 0;
                            e(33) = 0;
                            e(34) = p_max;
                            e(35) = -p_min;

                            % z_3の定義
                            e(36) = 0;
                            e(37) = 0;
                            e(38) = p_max;
                            e(39) = -p_min;

                        else
                            error('leader_flag is invalid.');
                        end

                        % e行列をtmp_E行列にプッシュ
                        tmp_E = [tmp_E; e];
                    end
                end

                % E行列にプッシュ
                E = [E, tmp_E];

            else
                % 車線を走査
                for lane_id = 1: num_lanes
                    % lane_prmを取得
                    lane_prm = LanePrmMap(lane_id);

                    % その車線の自動車のレコードを取得
                    tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                    % tmp_E行列を初期化
                    tmp_E = [];

                    % プロパティを取得
                    dt = obj.dt;
                    N_p = obj.N_p;

                    % 法定速度を取得
                    v = lane_prm.main.v;

                    % 位置の最大値と最小値を取得
                    if isempty(tmp_vehicles)
                        p_max = dt * N_p * v;
                        p_min = 0;
                    else
                        p_max = tmp_vehicles(1, :).pos + dt * N_p * v;
                        p_min = tmp_vehicles(end, :).pos;
                    end

                    % 分岐があるかどうかで場合分け
                    if isfield(lane_prm, 'branch')
                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % branch_flagによって場合分け
                            if vehicle.branch_flag == 1
                                % 必要なパラメータを取得
                                p_s = lane_prm.main.p_s;
                                D_s = lane_prm.main.D_s;
                                d_s = lane_prm.main.d_s;
                                D_f = lane_prm.main.D_f;
                                D_b = lane_prm.main.D_b;
                                D_o = lane_prm.main.D_o;
                                h_d_min = lane_prm.main.h_d(p_max);
                                h_p_min = lane_prm.main.h_p(p_min);
                                h_f_min = lane_prm.main.h_f(p_max, p_min);
                                h_b_min = lane_prm.main.h_b(p_max);
                                h_o_min = lane_prm.main.h_o(p_max);

                            elseif vehicle.branch_flag == 2 || vehicle.branch_flag == 3
                                % 必要なパラメータを取得
                                p_s = lane_prm.branch.p_s;
                                D_s = lane_prm.branch.D_s;
                                d_s = lane_prm.branch.d_s;
                                D_f = lane_prm.branch.D_f;
                                D_b = lane_prm.branch.D_b;
                                D_o = lane_prm.branch.D_o;
                                h_d_min = lane_prm.branch.h_d(p_max);
                                h_p_min = lane_prm.branch.h_p(p_min);
                                h_f_min = lane_prm.branch.h_f(p_max, p_min);
                                h_b_min = lane_prm.branch.h_b(p_max);
                                h_o_min = lane_prm.branch.h_o(p_max);

                            else
                                error('branch_flag is invalid.');
                            end
                            

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % e行列を初期化
                                e = zeros(18, 1);

                                % delta_1の定義
                                e(1) = -1;
                                e(2) = 1;
                                e(3) = 1;
                                e(4) = 1;

                                % delta_t1の定義
                                e(5) = -1;
                                e(6) = 1;
                                e(7) = 1;
                                e(8) = 1;

                                % delta_dの定義
                                e(9) = p_s - D_s - h_d_min;
                                e(10) = -p_s + D_s;

                                % delta_pの定義
                                e(11) = -p_s + d_s - h_p_min;
                                e(12) = p_s - d_s;

                                % delta_oの定義
                                e(13) = p_s - D_o - h_o_min;
                                e(14) = -p_s + D_o;

                                % z_1の定義
                                e(15) = 0;
                                e(16) = 0;
                                e(17) = p_max;
                                e(18) = -p_min;

                            elseif vehicle.leader_flag == 2
                                % e行列を初期化
                                e = zeros(34, 1);

                                % delta_1の定義
                                e(1) = -1;
                                e(2) = 1;
                                e(3) = 1;
                                e(4) = 1;

                                % delta_2の定義
                                e(5) = 1;
                                e(6) = 0;
                                e(7) = 0;
                                e(8) = 1;

                                % delta_t1の定義
                                e(9) = -1;  
                                e(10) = 1;
                                e(11) = 1;
                                e(12) = 1;

                                % delta_dの定義
                                e(13) = p_s - D_s - h_d_min;
                                e(14) = -p_s + D_s;

                                % delta_pの定義
                                e(15) = -p_s + d_s - h_p_min;
                                e(16) = p_s - d_s;

                                % delta_f2の定義
                                e(17) = D_f - h_f_min;
                                e(18) = -D_f;

                                % delta_bの定義
                                e(19) = p_s - D_b - h_b_min;
                                e(20) = -p_s + D_b;

                                % delta_oの定義
                                e(21) = p_s - D_o - h_o_min;
                                e(22) = -p_s + D_o;

                                % z_1の定義
                                e(23) = 0;
                                e(24) = 0;
                                e(25) = p_max;
                                e(26) = -p_min;

                                % z_2の定義
                                e(27) = 0;
                                e(28) = 0;
                                e(29) = p_max;
                                e(30) = -p_min;

                                % z_3の定義
                                e(31) = 0;
                                e(32) = 0;
                                e(33) = p_max;
                                e(34) = -p_min;
                            elseif vehicle.leader_flag == 3
                                % e行列を初期化
                                e = zeros(56, 1);

                                % delta_1の定義
                                e(1) = -1;
                                e(2) = 1;
                                e(3) = 1;
                                e(4) = 1;

                                % delta_2の定義
                                e(5) = 1;
                                e(6) = 0;
                                e(7) = 0;
                                e(8) = 1;

                                % delta_3の定義
                                e(9) = 0;
                                e(10) = 0;
                                e(11) = 1;
                                e(12) = 1;

                                % delta_t1の定義
                                e(13) = -1;
                                e(14) = 1;
                                e(15) = 1;
                                e(16) = 1;

                                % delta_t2の定義
                                e(17) = 1;
                                e(18) = 0;
                                e(19) = 0;
                                e(20) = 1;
                                e(21) = 1;

                                % delta_t3の定義
                                e(22) = 1;
                                e(23) = 0;
                                e(24) = 0;

                                % delta_dの定義
                                e(25) = p_s - D_s - h_d_min;
                                e(26) = -p_s + D_s;

                                % delta_pの定義
                                e(27) = -p_s + d_s - h_p_min;
                                e(28) = p_s - d_s;

                                % delta_f2の定義
                                e(29) = D_f - h_f_min;
                                e(30) = -D_f;

                                % delta_f3の定義
                                e(31) = D_f - h_f_min;
                                e(32) = -D_f;

                                % delta_bの定義
                                e(33) = p_s - D_b - h_b_min;
                                e(34) = -p_s + D_b;

                                % delta_oの定義
                                e(35) = p_s - D_o - h_o_min;
                                e(36) = -p_s + D_o;

                                % z_1の定義
                                e(37) = 0;
                                e(38) = 0;
                                e(39) = p_max;
                                e(40) = -p_min;

                                % z_2の定義
                                e(41) = 0;
                                e(42) = 0;
                                e(43) = p_max;
                                e(44) = -p_min;

                                % z_3の定義
                                e(45) = 0;
                                e(46) = 0;
                                e(47) = p_max;
                                e(48) = -p_min;

                                % z_4の定義
                                e(49) = 0;
                                e(50) = 0;
                                e(51) = p_max;
                                e(52) = -p_min;

                                % z_5の定義
                                e(53) = 0;
                                e(54) = 0;
                                e(55) = p_max;
                                e(56) = -p_min;

                            else
                                error('leader_flag is invalid.');
                            end

                            % e行列をtmp_E行列にプッシュ
                            tmp_E = [tmp_E; e];
                        end
                    else
                        % 必要なパラメータを取得
                        p_s = lane_prm.main.p_s;
                        D_s = lane_prm.main.D_s;
                        d_s = lane_prm.main.d_s;
                        D_f = lane_prm.main.D_f;
                        D_o = lane_prm.main.D_o;
                        h_d_min = lane_prm.main.h_d(p_max);
                        h_p_min = lane_prm.main.h_p(p_min);
                        h_f_min = lane_prm.main.h_f(p_max, p_min);
                        h_o_min = lane_prm.main.h_o(p_max);

                        % 自動車を走査
                        for record_id = 1: height(tmp_vehicles)
                            % レコードを取得
                            vehicle = tmp_vehicles(record_id, :);

                            % leader_flagによって場合分け
                            if vehicle.leader_flag == 1
                                % e行列を初期化
                                e = zeros(18, 1);

                                % delta_1の定義
                                e(1) = -1;
                                e(2) = 1;
                                e(3) = 1;
                                e(4) = 1;

                                % delta_t1の定義
                                e(5) = -1;
                                e(6) = 1;
                                e(7) = 1;
                                e(8) = 1;

                                % delta_dの定義
                                e(9) = p_s - D_s - h_d_min;
                                e(10) = -p_s + D_s;

                                % delta_pの定義
                                e(11) = -p_s + d_s - h_p_min;
                                e(12) = p_s - d_s;

                                % delta_oの定義
                                e(13) = p_s - D_o - h_o_min;
                                e(14) = -p_s + D_o;

                                % z_1の定義
                                e(15) = 0;
                                e(16) = 0;
                                e(17) = p_max;
                                e(18) = -p_min;

                            elseif vehicle.leader_flag == 3
                                % e行列を初期化
                                e = zeros(39, 1);

                                % delta_1の定義
                                e(1) = -1;
                                e(2) = 1;
                                e(3) = 1;
                                e(4) = 1;

                                % delta_2の定義
                                e(5) = 0;
                                e(6) = 0;
                                e(7) = 1;

                                % delta_t1の定義
                                e(8) = -1;
                                e(9) = 1;
                                e(10) = 1;
                                e(11) = 1;

                                % delta_t2の定義
                                e(12) = 1;
                                e(13) = 0;
                                e(14) = 0;
                                e(15) = 1;
                                e(16) = 1;

                                % delta_t3の定義
                                e(17) = 1;
                                e(18) = 0;
                                e(19) = 0;

                                % delta_dの定義
                                e(20) = p_s - D_s - h_d_min;
                                e(21) = -p_s + D_s;

                                % delta_pの定義
                                e(22) = -p_s + d_s - h_p_min;
                                e(23) = p_s - d_s;

                                % delta_f1の定義
                                e(24) = D_f - h_f_min;
                                e(25) = -D_f;

                                % delta_oの定義
                                e(26) = p_s - D_o - h_o_min;
                                e(27) = -p_s + D_o;

                                % z_1の定義
                                e(28) = 0;
                                e(29) = 0;
                                e(30) = p_max;
                                e(31) = -p_min;

                                % z_2の定義
                                e(32) = 0;
                                e(33) = 0;
                                e(34) = p_max;
                                e(35) = -p_min;

                                % z_3の定義
                                e(36) = 0;
                                e(37) = 0;
                                e(38) = p_max;
                                e(39) = -p_min;

                            else
                                error('leader_flag is invalid.');
                            end

                            % e行列をtmp_E行列にプッシュ
                            tmp_E = [tmp_E; e];
                        end
                    end

                    % tmp_E行列をE行列にプッシュ
                    E = [E; tmp_E];
                end
            end
        end

        % E行列をプッシュ
        obj.MLDsMap('E') = E;

    elseif strcmp(property_name, 'F1')
        % num_roadsを取得
        num_roads = obj.Roads.count();

        % num_signalsを取得
        num_signals = num_roads * (num_roads - 1);

        % delta_cの変数のリストを取得
        delta_c_list = obj.VariableListMap('delta_c');

        % F1行列を作成
        F1 = zeros(length(delta_c_list), num_signals);

        % F1行列をプッシュ
        obj.MLDsMap('F1') = F1;

    elseif strcmp(property_name, 'F2')
        % delta_cの変数のリストを取得
        delta_c_list = obj.VariableListMap('delta_c');

        % F2行列を作成
        F2 = zeros(length(delta_c_list), obj.z_length);

        % F2行列をプッシュ
        obj.MLDsMap('F2') = F2;

    elseif strcmp(property_name, 'F3')
        % F3行列を初期化
        F3 = [];

        % delta_cの変数のリストを取得
        delta_c_list = obj.VariableListMap('delta_c');

        for delta_c_id = delta_c_list
            % f3を初期化
            f3 = zeros(1, obj.delta_length);

            % 該当するdelta_cの変数の場所に1を代入
            f3(1, delta_c_id) = 1;

            % f3をF3行列にプッシュ
            F3 = [F3; f3];
        end

        % F行列をプッシュ
        obj.MLDsMap('F3') = F3;

    elseif strcmp(property_name, 'G')
        % delta_cの変数のリストを取得
        delta_c_list = obj.VariableListMap('delta_c');

        % H行列を作成
        G = ones(length(delta_c_list), 1);

        % G行列をプッシュ
        obj.MLDsMap('G') = G;

    elseif strcmp(property_name, 'B')
        % B1, B2, B3行列を取得
        B1 = obj.MLDsMap('B1');
        B2 = obj.MLDsMap('B2');
        B3 = obj.MLDsMap('B3');

        % B1, B2, B3行列を結合
        B = [B1, B2, B3];

        % B行列をプッシュ
        obj.MLDsMap('B') = B;

    elseif strcmp(property_name, 'D')
        % D1, D2, D3行列を取得
        D1 = obj.MLDsMap('D1');
        D2 = obj.MLDsMap('D2');
        D3 = obj.MLDsMap('D3');

        % D1, D2, D3行列を結合
        D = [D1, D2, D3];

        % D行列をプッシュ
        obj.MLDsMap('D') = D;        

    elseif strcmp(property_name, 'F')
        % F1, F2, F3行列を取得
        F1 = obj.MLDsMap('F1');
        F2 = obj.MLDsMap('F2');
        F3 = obj.MLDsMap('F3');

        % F1, F2, F3行列を結合
        F = [F1, F2, F3];

        % G行列をプッシュ
        obj.MLDsMap('F') = F;
        
    else
        error('Property name is invalid.');
    end
end