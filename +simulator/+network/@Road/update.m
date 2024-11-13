function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Networkクラスを取得
        Network = obj.Roads.get('Network');

        % current_timeを更新
        obj.current_time = Network.get('current_time');

    elseif strcmp(property_name, 'Vehicles')
        if isfield(obj.Intersections, 'input')
            if isprop(obj.Intersections.input, 'MPC')
                controller = 'MPC';
            elseif isprop(obj.Intersections.input, 'SCOOT')
                controller = 'SCOOT';
            else
                error('Not defined controller.');
            end
        else
            if isprop(obj, 'MPC')
                controller = 'MPC';
            elseif isprop(obj, 'SCOOT')
                controller = 'SCOOT';
            else
                error('Not defined controller.');
            end
        end

        if strcmp(controller, 'MPC')
            % 車両情報のテーブルを初期化
            size = [0, 7];
            variable_names = {'id', 'pos', 'route', 'stop_lane', 'branch_flag', 'leader_flag', 'preceding_record_id'};
            variable_types = {'double', 'double', 'double', 'double', 'double', 'double', 'double'};

            vehicles = table('Size', size, 'VariableNames', variable_names, 'VariableTypes', variable_types);

            % メインリンクのVehiclesのComオブジェクトを取得
            Vehicles = obj.links.main.Vissim.Vehs;

            if isprop(obj, 'routing_decision')
                % RouteOrderMapを取得
                RouteOrderMap = obj.routing_decision.routes.RouteOrderMap;

                % 各車両について走査
                for Vehicle = Vehicles.GetAll()'
                    % セルから取り出し
                    Vehicle = Vehicle{1};

                    % 車両情報を取得（id, pos, route）
                    id = Vehicle.get('AttValue', 'No');
                    pos = Vehicle.get('AttValue', 'Pos');
                    try 
                        route = RouteOrderMap(Vehicle.get('AttValue', 'RouteNo'));
                    catch
                        % ギリギリ道路に入ってきていてルートがまだ確定していないときの例外処理
                        route = RouteOrderMap(1);
                    end

                    % NextLinkを取得
                    NextLink = Vehicle.NextLink;

                    % stop_laneを取得
                    stop_lane = NextLink.FromLane.get('AttValue', 'Index');

                    % next_link_idを取得
                    next_link_id = NextLink.get('AttValue', 'No');

                    branch_flag = 1;

                    if isfield(obj.links, 'branch')
                        if isfield(obj.links.branch, 'left')
                            if next_link_id == obj.links.branch.left.connector.id
                                % branch_flagを取得
                                branch_flag = 3;
                            end
                        end

                        if isfield(obj.links.branch, 'right')
                            if next_link_id == obj.links.branch.right.connector.id
                                % branch_flagを取得
                                branch_flag = 2;
                            end
                        end
                    end

                    % 車両情報をテーブルにプッシュ
                    vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag, NaN, NaN};
                end

            else
                % 各車両について走査
                for Vehicle = Vehicles.GetAll()'
                    % セルから取り出し
                    Vehicle = Vehicle{1};

                    % 車両情報を取得（id, pos, route）
                    id = Vehicle.get('AttValue', 'No');
                    pos = Vehicle.get('AttValue', 'Pos');
                    route = -1;            

                    % stop_laneを取得
                    stop_lane = Vehicle.Lane.get('AttValue', 'Index');

                    % branch_flagを取得
                    branch_flag = 1;

                    % 車両情報をテーブルにプッシュ
                    vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag, NaN, NaN};
                end
            end

            
            % 分岐車線があるとき
            if isfield(obj.links, 'branch')
                for direction = ["left", "right"]

                    if isfield(obj.links.branch, direction)
                        % コネクタのComオブジェクトを取得
                        Connector = obj.links.branch.(direction).connector.Vissim;

                        % コネクタのfrom_posとto_posとlengthを取得
                        from_pos = obj.links.branch.(direction).connector.from_pos;
                        to_pos = obj.links.branch.(direction).connector.to_pos;
                        length = obj.links.branch.(direction).connector.length;

                        % VehiclesのCOMオブジェクトを取得
                        Vehicles = Connector.Vehs;

                        % 各車両を走査
                        for Vehicle = Vehicles.GetAll()'
                            % セルから取り出し
                            Vehicle = Vehicle{1};

                            % 車両情報を取得（id, pos, route）
                            id = Vehicle.get('AttValue', 'No');
                            pos = Vehicle.get('AttValue', 'Pos') + from_pos;
                            route = RouteOrderMap(Vehicle.get('AttValue', 'RouteNo'));

                            % stop_laneを取得
                            stop_lane = Connector.FromLane.get('AttValue', 'Index');

                            % branch_flagを取得
                            if direction == "left"
                                branch_flag = 3;
                            elseif direction == "right"
                                branch_flag = 2;
                            else 
                                error('error: direction is invalid.');
                            end

                            % 車両情報をテーブルにプッシュ
                            vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag, NaN, NaN};
                        end

                        % リンクのComオブジェクトを取得
                        Link = obj.links.branch.(direction).link.Vissim;

                        % VehiclesのCOMオブジェクトを取得
                        Vehicles = Link.Vehs;

                        % 各車両を走査
                        for Vehicle = Vehicles.GetAll()'
                            % セルから取り出し
                            Vehicle = Vehicle{1};

                            % 車両情報を取得（id, pos, route）
                            id = Vehicle.get('AttValue', 'No');
                            pos = Vehicle.get('AttValue', 'Pos') + length + from_pos - to_pos;
                            route = RouteOrderMap(Vehicle.get('AttValue', 'RouteNo'));

                            % stop_laneを取得
                            stop_lane = Connector.FromLane.get('AttValue', 'Index');

                            % branch_flagを取得
                            if direction == "left"
                                branch_flag = 3;
                            elseif direction == "right"
                                branch_flag = 2;
                            else 
                                error('error: direction is invalid.');
                            end

                            % 車両情報をテーブルにプッシュ
                            vehicles(end + 1, :) = {id, pos, route, stop_lane, branch_flag, NaN, NaN};
                        end
                    end
                end 
            end

            % vehiclesをソート
            vehicles = sortrows(vehicles, {'stop_lane', 'pos'}, {'ascend', 'descend'});

            % leader_flagの設定ここから

            % 車線数を取得
            num_lanes = obj.links.main.lanes;

            % 車線を走査
            for lane_id = 1: num_lanes
                % found_flagsを初期化
                found_flags = false(1, 3);

                % last_record_idsを初期化   
                last_record_ids = zeros(1, 3);

                % VehicleLeaderFlagMapとVehiclePrecedingRecordMapを初期化
                VehicleLeaderFlagMap = containers.Map('KeyType', 'double', 'ValueType', 'double');
                VehiclePrecedingRecordMap = containers.Map('KeyType', 'double', 'ValueType', 'double');

                % その車線の自動車のレコードを取得
                tmp_vehicles = vehicles(vehicles.stop_lane == lane_id, :);

                % 自動車を走査
                for record_id = 1: height(tmp_vehicles)
                    % レコードを取得
                    vehicle = tmp_vehicles(record_id, :);

                    % 一番先頭のレコードだった場合
                    if record_id == 1
                        % VehicleLeaderFlagMapにプッシュ
                        VehicleLeaderFlagMap(vehicle.id) = 1;

                        % VehiclePrecedingRecordMapにプッシュ
                        VehiclePrecedingRecordMap(vehicle.id) = NaN;

                        % found_flagsにプッシュ
                        found_flags(vehicle.branch_flag) = true;

                        % last_record_idsにプッシュ
                        last_record_ids(vehicle.branch_flag) = record_id;

                    else
                        if found_flags(vehicle.branch_flag)
                            % VehicleLeaderFlagMapにプッシュ
                            VehicleLeaderFlagMap(vehicle.id) = 3;

                            % VehiclePrecedingRecordMapにプッシュ
                            VehiclePrecedingRecordMap(vehicle.id) = last_record_ids(vehicle.branch_flag);

                            % last_record_idsにプッシュ
                            last_record_ids(vehicle.branch_flag) = record_id;
                        else
                            % VehicleLeaderFlagMapにプッシュ
                            VehicleLeaderFlagMap(vehicle.id) = 2;

                            % VehiclePrecedingRecordMapにプッシュ
                            VehiclePrecedingRecordMap(vehicle.id) = NaN;

                            % found_flagsにプッシュ
                            found_flags(vehicle.branch_flag) = true;

                            % last_record_idsにプッシュ
                            last_record_ids(vehicle.branch_flag) = record_id;
                        end
                    end
                end

                % VehicleLeaderFlagMapをvehiclesに反映
                for record_id = 1: height(tmp_vehicles)
                    % レコードを取得
                    vehicle = tmp_vehicles(record_id, :);

                    % leader_flagを取得
                    leader_flag = VehicleLeaderFlagMap(vehicle.id);

                    % preceding_record_idを取得
                    preceding_record_id = VehiclePrecedingRecordMap(vehicle.id);

                    % vehiclesに反映
                    vehicles(vehicles.id == vehicle.id, [6, 7]) = {leader_flag, preceding_record_id};
                end
            end

            % vehiclesをRoadにプッシュ
            obj.set('vehicles', vehicles);

        elseif strcmp(controller, 'SCOOT')
            % 現在のフェーズIDとフェーズの数を取得
            try
                current_phase_id = obj.SCOOT.get('current_phase_id');
                num_phases = obj.SCOOT.get('num_phases');
            catch
                SCOOT = obj.Intersection.input.get('SCOOT');
                current_phase_id = SCOOT.get('current_phase_id');
                num_phases = SCOOT.get('num_phases');
            end

            % inflowを取得
            if isprop(obj, 'InputDataCollectionsMap')
                if isprop(obj, 'PhaseInflowMap')
                    if obj.former_phase_id == current_phase_id
                        % inflowを取得
                        inflow = obj.PhaseInflowMap(current_phase_id);
                    else
                        % inflowを初期化
                        inflow = 0;
                    end
                else
                    % inflowを初期化
                    inflow = 0;
                    
                    % PhaseInflowMapを初期化
                    PhaseInflowMap = containers.Map('KeyType', 'int32', 'ValueType', 'double');

                    % phase_idを走査
                    for phase_id = 1: num_phases
                        PhaseInflowMap(phase_id) = 0;
                    end

                    % PhaseInflowMapをRoadにプッシュ
                    obj.set('PhaseInflowMap', PhaseInflowMap);

                    % former_phase_idを初期化
                    obj.set('former_phase_id', current_phase_id);
                end
            end

            % outflowを取得
            if isprop(obj, 'PhaseOutflowMap')
                if obj.former_phase_id == current_phase_id
                    % outflowを取得
                    outflow = obj.PhaseOutflowMap(current_phase_id);
                else
                    % outflowを初期化
                    outflow = 0;
                end
            else
                % outflowを初期化
                outflow = 0;

                % PhaseOutflowMapを初期化
                PhaseOutflowMap = containers.Map('KeyType', 'int32', 'ValueType', 'double');

                % phase_idを走査
                for phase_id = 1: num_phases
                    PhaseOutflowMap(phase_id) = 0;
                end

                % PhaseOutflowMapをRoadにプッシュ
                obj.set('PhaseOutflowMap', PhaseOutflowMap);

                % former_phase_idを初期化
                obj.set('former_phase_id', current_phase_id);
            end

            % InputDataCollectionを走査
            if isprop(obj, 'InputDataCollectionsMap')
                for data_collection_id = cell2mat(obj.InputDataCollectionsMap.keys())
                    % InputDataCollectionのComオブジェクトを取得
                    InputDataCollection = obj.InputDataCollectionsMap(data_collection_id);

                    % このステップで通過した自動車台数を取得
                    num_vehs = InputDataCollection.get('AttValue', 'Vehs(Current, Last, All)');

                    % inflowにプッシュ
                    inflow = inflow + num_vehs;
                end

                % inflowをPhaseInflowMapにプッシュ
                obj.PhaseInflowMap(current_phase_id) = inflow;
            end

            % OutputDataCollectionを走査
            for data_collection_id = cell2mat(obj.OutputDataCollectionsMap.keys())
                % OutputDataCollectionのComオブジェクトを取得
                OutputDataCollection = obj.OutputDataCollectionsMap(data_collection_id);

                % このステップで通過した自動車台数を取得
                num_vehs = OutputDataCollection.get('AttValue', 'Vehs(Current, Last, All)');

                % outflowにプッシュ
                outflow = outflow + num_vehs;
            end

            % outflowをPhaseOutflowMapにプッシュ
            obj.PhaseOutflowMap(current_phase_id) = outflow;

            % former_phase_idを更新
            obj.former_phase_id = current_phase_id;

        else
            error('Method is invalid.');
        end

    elseif strcmp(property_name, 'DataCollections')
        % DataCollectionsを初期化
        obj.DataCollections.input = simulator.network.DataCollections(obj);
        obj.DataCollections.output = simulator.network.DataCollections(obj);
        
    elseif strcmp(property_name, 'Evaluation')
        % queue_tableが存在するとき
        if isprop(obj, 'queue_table')
            % queue_tableの更新
            obj.update('queue_table');
        end

        % delay_tableが存在するとき
        if isprop(obj, 'delay_table')
            % delay_tableの更新
            obj.update('delay_table');
        end

    elseif strcmp(property_name, 'queue_table')
        % メインリンクのQueueCounterのComオブジェクトを取得
        QueueCounter = obj.queue_counters.main.Vissim;

        % queue_lengthを取得
        queue_length = round(QueueCounter.get('AttValue', 'QLen(Current, Last)'), 1);

        % NaNの場合は0に変換
        if isnan(queue_length)
            queue_length = 0;
        end

        % average_queue_lengthとmax_queue_lengthを初期化
        average_queue_length = queue_length;
        max_queue_length = queue_length;

        % 分岐車線があるとき
        if isfield(obj.queue_counters, 'branch')
            % 分岐の数を初期化
            num_branch = 0;

            for direction = ["left", "right"]
                % char型に変換
                direction = char(direction);

                % direcitionに対応する分岐が存在する場合
                if isfield(obj.queue_counters.branch, direction)
                    % メインリンクの車線数を取得
                    main_num_lanes = obj.links.main.lanes;

                    % branch構造体を取得
                    branch = obj.queue_counters.branch.(direction);

                    % QueueCounterのComオブジェクトを取得
                    QueueCounter = branch.Vissim;

                    % queue_lengthを取得
                    queue_length = round(QueueCounter.get('AttValue', 'QLen(Current, Last)'), 1);

                    % NaNの場合は0に変換
                    if isnan(queue_length)
                        queue_length = 0;
                    end

                    % num_branchを更新
                    num_branch = num_branch + 1;

                    % average_queue_lengthとmax_queue_lengthを更新
                    average_queue_length = average_queue_length + 1/(main_num_lanes + num_branch) * (queue_length - average_queue_length);
                    max_queue_length = max(max_queue_length, queue_length);
                end
            end
        end

        % queue_tableにプッシュ
        obj.queue_table(end + 1, :) = {obj.current_time, round(average_queue_length, 1), round(max_queue_length, 1)};
    elseif strcmp(property_name, 'delay_table')
        % RouteAverageDelayMapとRouteNumMeasurementsMapを初期化
        RouteAverageDelayMap = containers.Map('KeyType', 'int32', 'ValueType', 'double');
        RouteNumMeasurementsMap = containers.Map('KeyType', 'int32', 'ValueType', 'double');

        % delay_measurementを走査
        for delay_measurement = obj.delay_measurements
            % route_idを取得
            route_id = delay_measurement.route_id;

            % DelayMeasurementのComオブジェクトを取得
            DelayMeasurement = delay_measurement.Vissim;

            % delay_timeを取得
            delay_time = round(DelayMeasurement.get('AttValue', 'VehDelay(Current, Last, All)'), 1);

            % NaNの場合は0に変換
            if isnan(delay_time)
                delay_time = 0;
            end

            % 最初の測定ではないかつdelay_timeが0の場合
            if height(obj.delay_table) ~= 0 && delay_time == 0
                % colume_nameを作成
                column_name = sprintf('route_%d', route_id);

                % 前の値を取得
                delay_time = obj.delay_table{end, column_name};
            end

            % RouteNumMeasurementsMapにプッシュ
            if isKey(RouteNumMeasurementsMap, route_id)
                RouteNumMeasurementsMap(route_id) = RouteNumMeasurementsMap(route_id) + 1;
            else
                RouteNumMeasurementsMap(route_id) = 1;
            end

            % RouteAverageDelayMapにプッシュ
            if isKey(RouteAverageDelayMap, route_id)
                RouteAverageDelayMap(route_id) = round(RouteAverageDelayMap(route_id) + 1/RouteNumMeasurementsMap(route_id) * (delay_time - RouteAverageDelayMap(route_id)), 1);
            else
                RouteAverageDelayMap(route_id) = delay_time;
            end
        end

        % new_recordを初期化
        new_record = {obj.current_time};

        % route_idsを作成
        route_ids = sort(cell2mat(RouteAverageDelayMap.keys), 'ascend');

        % RouteAverageDelayMapを走査
        for route_id = route_ids
            % new_recordにプッシュ
            new_record{end + 1} = RouteAverageDelayMap(route_id);
        end

        % delay_tableにプッシュ
        obj.delay_table(end + 1, :) = new_record;
    else
        error('error: Property name is invalid.');
    end
end