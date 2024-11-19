function update(obj, property_name)
    if strcmp(property_name, 'Vehicles')
        if isfield(obj.Intersections, 'output')
            if isprop(obj.Intersections.output.get('Controller'), 'Mpc')
                controller = 'Mpc';
            elseif isprop(obj.Intersections.output.get('Controller'), 'Scoot')
                controller = 'Scoot';
            else
                error('Not defined controller.');
            end
        else
            if isprop(obj.Intersections.input.get('Controller'), 'Mpc')
                controller = 'Mpc';
            elseif isprop(obj.Intersections.input.get('Controller'), 'Scoot')
                controller = 'Scoot';
            else
                error('Not defined controller.');
            end
        end

        if strcmp(controller, 'Mpc')
            % 車両情報のテーブルを初期化
            variable_size = [0, 7];
            variable_names = {'id', 'pos', 'route', 'stop_lane', 'branch_flag', 'leader_flag', 'preceding_record_id'};
            variable_types = {'double', 'double', 'double', 'double', 'double', 'double', 'double'};

            vehicles = table('Size', variable_size, 'VariableNames', variable_names, 'VariableTypes', variable_types);

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

        elseif strcmp(controller, 'Scoot')
            % 現在のフェーズIDとフェーズの数を取得
            if isfield(obj.Intersections, 'output')
                % Scootクラスを取得
                Scoot = obj.Intersections.output.get('Controller').get('Scoot');

                % phase_idsを取得
                phase_ids = Scoot.get('phase_ids');

                % current_phase_idとnum_phasesを取得
                current_phase_id = phase_ids(1);
                num_phases = size(phase_ids, 1);

            elseif isfield(obj.Intersections, 'input')
                % Scootクラスを取得
                Scoot = obj.Intersections.input.get('Controller').get('Scoot');

                % phase_idsを取得
                phase_ids = Scoot.get('phase_ids');

                % current_phase_idとnum_phasesを取得
                current_phase_id = phase_ids(1);
                num_phases = size(phase_ids, 1);
            else
                error('error: Intersection is invalid.');
            end

            % inflowを取得
            if isfield(obj.DataCollections, 'input')
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
            if isfield(obj.DataCollections, 'input')
                for data_collection_id = obj.DataCollections.input.getKeys()
                    % DataCollectionクラスを取得
                    DataCollection = obj.DataCollections.input.itemByKey(data_collection_id);

                    % このステップで通過した自動車台数を取得
                    num_vehs = DataCollection.get('Vissim').get('AttValue', 'Vehs(Current, Last, All)');

                    % inflowにプッシュ
                    inflow = inflow + num_vehs;
                end

                % inflowをPhaseInflowMapにプッシュ
                obj.PhaseInflowMap(current_phase_id) = inflow;
            end

            % 流出側のDataCollectionを走査
            for data_collection_id = obj.DataCollections.output.getKeys()
                % DataCollectionクラスを取得
                DataCollection = obj.DataCollections.output.itemByKey(data_collection_id);

                % このステップで通過した自動車台数を取得
                num_vehs = DataCollection.get('Vissim').get('AttValue', 'Vehs(Current, Last, All)');

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
        
    elseif strcmp(property_name, 'Evaluation')
        % 流出交差点が存在する場合
        if isfield(obj.Intersections, 'output')
            if obj.record_flags.queue_length
                % QueueCountersのqueue_tableを更新
                obj.QueueCounters.update('queue_table');
            end

            if obj.record_flags.delay_time
                % DelayMeasurementsのdelay_tableを更新
                obj.DelayMeasurements.update('delay_table');
            end
        end
    else
        error('error: Property name is invalid.');
    end
end