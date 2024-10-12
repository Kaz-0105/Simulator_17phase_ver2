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
                B1 = blkdiag(B1, tmp_B1);
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
                    B1 = blkdiag(B1, tmp_B1);
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

                            % delta_d^primeの定義
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

                            % delta_d^primeの定義
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
                            c = zeros(53, num_vehicles);

                            % delta_dの定義
                            c(22, record_id) = 1;
                            c(23, record_id) = -1;

                            % delta_pの定義
                            c(24, record_id) = -1;
                            c(25, record_id) = 1;

                            % delta_f2の定義
                            c(26, [record_id - 1, record_id]) = [1, -1];
                            c(27, [record_id - 1, record_id]) = [-1, 1];

                            % 先行車のIDを取得
                            preceding_record_id = vehicle.preceding_record_id;

                            % delta_f3の定義
                            c(28, [preceding_record_id, record_id]) = [1, -1];
                            c(29, [preceding_record_id, record_id]) = [-1, 1];

                            % delta_bの定義
                            c(30, record_id) = 1;
                            c(31, record_id) = -1;

                            % delta_d^primeの定義
                            c(32, record_id) = 1;
                            c(33, record_id) = -1;

                            % z_1の定義
                            c(36, record_id) = 1;
                            c(37, record_id) = -1;

                            % z_2の定義
                            c(40, record_id - 1) = 1;
                            c(41, record_id - 1) = -1;

                            % z_3の定義
                            c(44, record_id) = 1;
                            c(45, record_id) = -1;

                            % z_4の定義
                            c(48, preceding_record_id) = 1;
                            c(49, preceding_record_id) = -1;

                            % z_5の定義
                            c(52, record_id) = 1;
                            c(53, record_id) = -1;
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

                            % delta_d^primeの定義
                            c(13, record_id) = 1;
                            c(14, record_id) = -1;

                            % z_1の定義
                            c(17, record_id) = 1;
                            c(18, record_id) = -1;

                        elseif vehicle.leader_flag == 3
                            % c行列を初期化
                            c = zeros(36, num_vehicles);

                            % delta_dの定義
                            c(17, record_id) = 1;
                            c(18, record_id) = -1;

                            % delta_pの定義
                            c(19, record_id) = -1;
                            c(20, record_id) = 1;

                            % delta_fの定義
                            c(21, [record_id - 1, record_id]) = [1, -1];
                            c(22, [record_id - 1, record_id]) = [-1, 1];

                            % delta_d^primeの定義
                            c(23, record_id) = 1;
                            c(24, record_id) = -1;

                            % z_1の定義
                            c(27, record_id) = 1;
                            c(28, record_id) = -1;

                            % z_2の定義
                            c(31, record_id - 1) = 1;
                            c(32, record_id - 1) = -1;

                            % z_3の定義
                            c(35, record_id) = 1;
                            c(36, record_id) = -1;
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
                            vehicle = tmp_vehicle(record_id, :);

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

                                % delta_d^primeの定義
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

                                % delta_d^primeの定義
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
                                c = zeros(53, num_vehicles);

                                % delta_dの定義
                                c(22, record_id) = 1;
                                c(23, record_id) = -1;

                                % delta_pの定義
                                c(24, record_id) = -1;
                                c(25, record_id) = 1;

                                % delta_f2の定義
                                c(26, [record_id - 1, record_id]) = [1, -1];
                                c(27, [record_id - 1, record_id]) = [-1, 1];

                                % 先行車のIDを取得
                                preceding_record_id = vehicle.preceding_record_id;

                                % delta_f3の定義
                                c(28, [preceding_record_id, record_id]) = [1, -1];
                                c(29, [preceding_record_id, record_id]) = [-1, 1];

                                % delta_bの定義
                                c(30, record_id) = 1;
                                c(31, record_id) = -1;

                                % delta_d^primeの定義
                                c(32, record_id) = 1;
                                c(33, record_id) = -1;

                                % z_1の定義
                                c(36, record_id) = 1;
                                c(37, record_id) = -1;

                                % z_2の定義
                                c(40, record_id - 1) = 1;
                                c(41, record_id - 1) = -1;

                                % z_3の定義
                                c(44, record_id) = 1;
                                c(45, record_id) = -1;

                                % z_4の定義
                                c(48, preceding_record_id) = 1;
                                c(49, preceding_record_id) = -1;

                                % z_5の定義
                                c(52, record_id) = 1;
                                c(53, record_id) = -1;
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
    
                                % delta_d^primeの定義
                                c(13, record_id) = 1;
                                c(14, record_id) = -1;
    
                                % z_1の定義
                                c(17, record_id) = 1;
                                c(18, record_id) = -1;
    
                            elseif vehicle.leader_flag == 3
                                % c行列を初期化
                                c = zeros(36, num_vehicles);
    
                                % delta_dの定義
                                c(17, record_id) = 1;
                                c(18, record_id) = -1;
    
                                % delta_pの定義
                                c(19, record_id) = -1;
                                c(20, record_id) = 1;
    
                                % delta_fの定義
                                c(21, [record_id - 1, record_id]) = [1, -1];
                                c(22, [record_id - 1, record_id]) = [-1, 1];
    
                                % delta_d^primeの定義
                                c(23, record_id) = 1;
                                c(24, record_id) = -1;
    
                                % z_1の定義
                                c(27, record_id) = 1;
                                c(28, record_id) = -1;
    
                                % z_2の定義
                                c(31, record_id - 1) = 1;
                                c(32, record_id - 1) = -1;
    
                                % z_3の定義
                                c(35, record_id) = 1;
                                c(36, record_id) = -1;
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
                            d1 = zeros(53, num_signals);

                            % delta_1の定義
                            d1(1, signal_id) = -1;
                            d1(2, signal_id) = 1;

                            % delta_t1の定義
                            d1(13, signal_id) = -1;
                            d1(14, signal_id) = 1;

                            % delta_t2の定義
                            d1(17, signal_id) = 1;
                            d1(18, signal_id) = -1;
                            
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
                            d1 = zeros(36, num_signals);

                            % delta_1の定義
                            d1(1, signal_id) = -1;
                            d1(2, signal_id) = 1;

                            % delta_t1の定義
                            d1(8, signal_id) = -1;
                            d1(9, signal_id) = 1;

                            % delta_t2の定義
                            d1(12, signal_id) = 1;
                            d1(13, signal_id) = -1;

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
                                d1 = zeros(53, num_signals);

                                % delta_1の定義
                                d1(1, signal_id) = -1;
                                d1(2, signal_id) = 1;

                                % delta_t1の定義
                                d1(13, signal_id) = -1;
                                d1(14, signal_id) = 1;

                                % delta_t2の定義
                                d1(17, signal_id) = 1;
                                d1(18, signal_id) = -1;
                                
                            else
                                error('leader_flag is invalid.');
                            end

                            % d1行列をtmp_D1行列にプッシュ
                            tmp_D1 = [tmp_D1; d1];
                        end
                    else
                        % 自動車を走査
                        for record_id = 1: height(record_id)
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
                                d1 = zeros(36, num_signals);

                                % delta_1の定義
                                d1(1, signal_id) = -1;
                                d1(2, signal_id) = 1;

                                % delta_t1の定義
                                d1(8, signal_id) = -1;
                                d1(9, signal_id) = 1;

                                % delta_t2の定義
                                d1(12, signal_id) = 1;
                                d1(13, signal_id) = -1;
                                
                            else
                                error('leader_flag is invalid.');
                            end

                            % d1行列をtmp_D1行列にプッシュ
                            tmp_D1 = [tmp_D1; d1];
                        end
                    end

                    % D1行列にプッシュ
                    D1 = [D1, tmp_D1];

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
                            d2 = zeros(53, 5);

                            % z_1の定義
                            d2(34, 1) = -1;
                            d2(35, 1) = 1;
                            d2(36, 1) = -1;
                            d2(37, 1) = 1;

                            % z_2の定義
                            d2(38, 2) = -1;
                            d2(39, 2) = 1;
                            d2(40, 2) = -1;
                            d2(41, 2) = 1;

                            % z_3の定義
                            d2(42, 3) = -1;
                            d2(43, 3) = 1;
                            d2(44, 3) = -1;
                            d2(45, 3) = 1;

                            % z_4の定義
                            d2(46, 4) = -1;
                            d2(47, 4) = 1;
                            d2(48, 4) = -1;
                            d2(49, 4) = 1;

                            % z_5の定義
                            d2(50, 5) = -1;
                            d2(51, 5) = 1;
                            d2(52, 5) = -1;
                            d2(53, 5) = 1;

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
                            d2 = zeros(36, 3);

                            % z_1の定義
                            d2(25, 1) = -1;
                            d2(26, 1) = 1;
                            d2(27, 1) = -1;
                            d2(28, 1) = 1;

                            % z_2の定義
                            d2(29, 2) = -1;
                            d2(30, 2) = 1;
                            d2(31, 2) = -1;
                            d2(32, 2) = 1;

                            % z_3の定義
                            d2(33, 3) = -1;
                            d2(34, 3) = 1;
                            d2(35, 3) = -1;
                            d2(36, 3) = 1;

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
                                d2 = zeros(53, 5);

                                % z_1の定義
                                d2(34, 1) = -1;
                                d2(35, 1) = 1;
                                d2(36, 1) = -1;
                                d2(37, 1) = 1;

                                % z_2の定義
                                d2(38, 2) = -1;
                                d2(39, 2) = 1;
                                d2(40, 2) = -1;
                                d2(41, 2) = 1;

                                % z_3の定義
                                d2(42, 3) = -1;
                                d2(43, 3) = 1;
                                d2(44, 3) = -1;
                                d2(45, 3) = 1;

                                % z_4の定義
                                d2(46, 4) = -1;
                                d2(47, 4) = 1;
                                d2(48, 4) = -1;
                                d2(49, 4) = 1;

                                % z_5の定義
                                d2(50, 5) = -1;
                                d2(51, 5) = 1;
                                d2(52, 5) = -1;
                                d2(53, 5) = 1;

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
                                d2 = zeros(36, 3);

                                % z_1の定義
                                d2(25, 1) = -1;
                                d2(26, 1) = 1;
                                d2(27, 1) = -1;
                                d2(28, 1) = 1;

                                % z_2の定義
                                d2(29, 2) = -1;
                                d2(30, 2) = 1;
                                d2(31, 2) = -1;
                                d2(32, 2) = 1;

                                % z_3の定義
                                d2(33, 3) = -1;
                                d2(34, 3) = 1;
                                d2(35, 3) = -1;
                                d2(36, 3) = 1;

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

            % 車線数で場合分け
            if num_lanes == 1
                % lane_prmを取得
                lane_prm = LanePrmMap(1);

                % tmp_D3行列を初期化
                tmp_D3 = [];

                % 分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')
                    % 自動車を走査
                    for record_id = 1: height(vehicles)
                    end

                    % D3行列にプッシュ
                    D3 = blkdiag(D3, tmp_D3);
                else
                end
            else
            end
        end
    elseif strcmp(property_name, 'E')
    else
        error('Property name is invalid.');
    end
end