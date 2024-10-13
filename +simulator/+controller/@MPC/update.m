function update(obj, property_name)
    if strcmp(property_name, 'model')
        % 変数のリストを作成
        obj.update('VariableListMap');

        % MLDの行列の更新
        obj.update('MLD');

        % MILPの行列の更新
        obj.update('MILP');

    elseif strcmp(property_name, 'MLD')
        % MLDsMapの初期化
        obj.MLDsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

        % A行列の更新
        obj.updateMLD('A');

        % B1行列の更新
        obj.updateMLD('B1');

        % B2行列の更新
        obj.updateMLD('B2');

        % B3行列の更新
        obj.updateMLD('B3');

        % C行列の更新
        obj.updateMLD('C');

        % D1行列の更新
        obj.updateMLD('D1');

        % D2行列の更新
        obj.updateMLD('D2');

        % D3行列の更新
        obj.updateMLD('D3');

        % E行列の更新
        obj.updateMLD('E');

        % validateを実行
        obj.validate('MLD');

    elseif strcmp(property_name, 'MILP')
        % MILPsMapの初期化
        obj.MILPsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

        % 不等式制約（P, q）、等式制約（Peq, qeq）の更新
        obj.updateMILP('Constraints');

        % 目的関数（f）の更新
        obj.updateMILP('Objective');

        % 整数制約（intcon）の更新
        obj.updateMILP('Intcon');

        % 変域（lb, ub）の更新
        obj.updateMILP('Bounds');
    elseif strcmp(property_name, 'VariableListMap')
        % VariableListMapの初期化
        obj.VariableListMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

        % リストを初期化
        delta_ds = [];
        delta_ps = [];
        delta_f1s = [];
        delta_f2s = [];
        delta_f3s = [];
        delta_bs = [];
        delta_os = [];
        delta_1s = [];
        delta_2s = [];
        delta_3s = [];
        delta_t1s = [];
        delta_t2s = [];
        delta_t3s = [];
        delta_cs = [];


        % 変数のカウンターを初期化
        counter = 0;

        % 道路を走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % road_prmを取得
            road_prm = obj.RoadPrmMap(road_id);

            % LanePrmMapを取得
            LanePrmMap = road_prm.LanePrmMap;

            % 車線数を取得
            num_lanes = LanePrmMap.Count();

            % vehiclesを取得
            vehicles = Road.get('vehicles');

            % 車線を走査
            for lane_id = 1: num_lanes
                % tmp_vehiclesを取得
                tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                % lane_prmを取得
                lane_prm = LanePrmMap(lane_id);

                % 分岐があるかどうかで場合分け
                if isfield(lane_prm, 'branch')
                    % 自動車を走査
                    for record_id = 1: height(tmp_vehicles)
                        % レコードを取得
                        vehicle = tmp_vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % 変数を追加
                            delta_ds(1, end + 1) = counter + 1;
                            delta_ps(1, end + 1) = counter + 2;
                            delta_os(1, end + 1) = counter + 3;
                            delta_1s(1, end + 1) = counter + 4;
                            delta_t1s(1, end + 1) = counter + 5;
                            delta_cs(1, end + 1) = counter + 6;

                            % カウンターを更新
                            counter = counter + 6;

                        elseif vehicle.leader_flag == 2
                            % 変数を追加
                            delta_ds(1, end + 1) = counter + 1;
                            delta_ps(1, end + 1) = counter + 2;
                            delta_f2s(1, end + 1) = counter + 3;
                            delta_bs(1, end + 1) = counter + 4;
                            delta_os(1, end + 1) = counter + 5;
                            delta_1s(1, end + 1) = counter + 6;
                            delta_2s(1, end + 1) = counter + 7;
                            delta_t1s(1, end + 1) = counter + 8;
                            delta_cs(1, end + 1) = counter + 9;

                            % カウンターを更新
                            counter = counter + 9;

                        elseif vehicle.leader_flag == 3
                            % 変数を追加
                            delta_ds(1, end + 1) = counter + 1;
                            delta_ps(1, end + 1) = counter + 2;
                            delta_f2s(1, end + 1) = counter + 3;
                            delta_f3s(1, end + 1) = counter + 4;
                            delta_bs(1, end + 1) = counter + 5;
                            delta_os(1, end + 1) = counter + 6;
                            delta_1s(1, end + 1) = counter + 7;
                            delta_2s(1, end + 1) = counter + 8;
                            delta_3s(1, end + 1) = counter + 9;
                            delta_t1s(1, end + 1) = counter + 10;
                            delta_t2s(1, end + 1) = counter + 11;
                            delta_t3s(1, end + 1) = counter + 12;
                            delta_cs(1, end + 1) = counter + 13;

                            % カウンターを更新
                            counter = counter + 13;
                        else
                            error('Error: leader_flag is invalid.');
                        end
                    end    
                else
                    % 自動車を走査
                    for record_id = 1: height(tmp_vehicles)
                        % レコードを取得
                        vehicle = tmp_vehicles(record_id, :);

                        % leader_flagによって場合分け
                        if vehicle.leader_flag == 1
                            % 変数を追加
                            delta_ds(1, end + 1) = counter + 1;
                            delta_ps(1, end + 1) = counter + 2;
                            delta_os(1, end + 1) = counter + 3;
                            delta_1s(1, end + 1) = counter + 4;
                            delta_t1s(1, end + 1) = counter + 5;
                            delta_cs(1, end + 1) = counter + 6;

                            % カウンターを更新
                            counter = counter + 6;

                        elseif vehicle.leader_flag == 3
                            % 変数を追加
                            delta_ds(1, end + 1) = counter + 1;
                            delta_ps(1, end + 1) = counter + 2;
                            delta_f1s(1, end + 1) = counter + 3;
                            delta_os(1, end + 1) = counter + 4;
                            delta_1s(1, end + 1) = counter + 5;
                            delta_2s(1, end + 1) = counter + 6;
                            delta_t1s(1, end + 1) = counter + 7;
                            delta_t2s(1, end + 1) = counter + 8;
                            delta_t3s(1, end + 1) = counter + 9;
                            delta_cs(1, end + 1) = counter + 10;
                            
                            % カウンターを更新
                            counter = counter + 10;
                        else
                            error('Error: leader_flag is invalid.');
                        end
                    end
                end
            end
        end

        % 変数リストを更新
        obj.VariableListMap('delta_d') = delta_ds;
        obj.VariableListMap('delta_p') = delta_ps;
        obj.VariableListMap('delta_f1') = delta_f1s;
        obj.VariableListMap('delta_f2') = delta_f2s;
        obj.VariableListMap('delta_f3') = delta_f3s;
        obj.VariableListMap('delta_b') = delta_bs;
        obj.VariableListMap('delta_o') = delta_os;
        obj.VariableListMap('delta_1') = delta_1s;
        obj.VariableListMap('delta_2') = delta_2s;
        obj.VariableListMap('delta_3') = delta_3s;
        obj.VariableListMap('delta_t1') = delta_t1s;
        obj.VariableListMap('delta_t2') = delta_t2s;
        obj.VariableListMap('delta_t3') = delta_t3s;
        obj.VariableListMap('delta_c') = delta_cs;

    else
        error('Error: property name is invalid.');  
    end
end