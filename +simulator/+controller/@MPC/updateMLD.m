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

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % 車線数を取得
            links = Road.get('links');
            num_lanes = links.main.lanes;

            % signal_groupの数を取得
            Intersection = Road.get('OutputIntersection');
            signal_controller = Intersection.get('signal_controller');
            SignalGroupsMap = signal_controller.signal_groups.SignalGroupsMap;
            num_signal_groups = SignalGroupsMap.Count();


            % 車線の数で場合分け
            if num_lanes == 1
                % 自動車台数を取得
                num_vehicles = height(vehicles);

                % tmp_B1行列を作成
                tmp_B1 = zeros(num_vehicles, num_signal_groups);

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
                    tmp_B1 = zeros(num_vehicles, num_signal_groups);

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

            % 車線数を取得
            links = Road.get('links');
            num_lanes = links.main.lanes;

            % road_prmを取得
            road_prm = obj.RoadParameterMap(road_id);

            % LaneParameterMapを取得
            LaneParameterMap = road_prm.LaneParameterMap;

            % 車線の数で場合分け
            if num_lanes == 1
                % lane_prmを取得
                lane_prm = LaneParameterMap(1);

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
                    lane_prm = LaneParameterMap(lane_id);

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
    elseif strcmp(property_name, 'C')
    elseif strcmp(property_name, 'D1')
    elseif strcmp(property_name, 'D2')
    elseif strcmp(property_name, 'D3')
    elseif strcmp(property_name, 'E')
    else
        error('Property name is invalid.');
    end
end