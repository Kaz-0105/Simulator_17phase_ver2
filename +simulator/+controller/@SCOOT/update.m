function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Simulatorクラスを取得
        Controllers = obj.Controller.get('Controllers');
        Simulator = Controllers.get('Simulator');

        % current_timeを取得
        obj.current_time = Simulator.get('current_time');

    elseif strcmp(property_name, 'skip_flag')
        if obj.current_phase_id < obj.num_phases
            next_split_start = obj.PhaseSplitStartMap(obj.current_phase_id + 1);
        elseif obj.current_phase_id == obj.num_phases
            next_split_start = obj.PhaseSplitStartMap(1);
        end

        obj.skip_flag = true;
        obj.objectives = [];

        if obj.current_time + obj.delta_s + 1 == next_split_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "split"];
        end

        if obj.current_time + 1 == obj.next_cycle_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "cycle"];
        end

        if obj.current_time == obj.next_split_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "split_change"];
        end

        if obj.current_time == obj.next_cycle_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "cycle_change"];
        end

    elseif strcmp(property_name, 'PhaseSaturationMap')
        
        % inflow_rata, outflow_rateを取得
        inflow_rate = obj.PhaseInflowRateMap(obj.current_phase_id);
        outflow_rate = obj.PhaseOutflowRateMap(obj.current_phase_id);

        % PhaseSaturationMapを更新
        obj.PhaseSaturationMap(obj.current_phase_id) = inflow_rate / outflow_rate;
        
    elseif strcmp(property_name, 'PhaseInflowRateMap')
        % inflowを初期化
        inflow = 0;

        % 現在のフェーズによって更新部分に必要なIDが異なるため、分岐処理を行う
        if obj.Roads.count() == 4
            if obj.current_phase_id == 1
                road_ids = [1, 3];
                order_ids = [1, 2];
            elseif obj.current_phase_id == 2
                road_ids = [1, 3];
                order_ids = 3;
            elseif obj.current_phase_id == 3
                road_ids = [2, 4];
                order_ids = [1, 2];
            elseif obj.current_phase_id == 4
                road_ids = [2, 4];
                order_ids = 3;
            else
                error('current_phase_id is invalid.');
            end
        elseif obj.Roads.count() == 3
            error('Not implemented yet.');
        else
            error('Not defined number of roads.');
        end

        
        % Roadクラスを走査
        for road_id = road_ids
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % RoadクラスからPhaseInflowMapを取得
            PhaseInflowMap = Road.get('PhaseInflowMap');

            % tmp_inflowを初期化
            tmp_inflow = 0;

            % phase_idを走査
            for phase_id = 1: PhaseInflowMap.Count()
                tmp_inflow = tmp_inflow + PhaseInflowMap(phase_id);
            end

            % target_rel_flowとtotal_rel_flowを初期化
            target_rel_flow = 0;
            total_rel_flow = 0;

            % routesを取得
            routes = Road.get('routing_decision').routes;

            % RoutesMapとRouteOrderMapを取得
            RoutesMap = routes.RoutesMap;
            RouteOrderMap = routes.RouteOrderMap;

            % routeを走査
            for route_id = 1: RoutesMap.Count()
                % routeを取得
                route = RoutesMap(route_id);

                % order_idを取得
                order_id = RouteOrderMap(route_id);

                % order_idがorder_idsに含まれる場合
                if ismember(order_id, order_ids)
                    % target_rel_flowを更新
                    target_rel_flow = target_rel_flow + route.rel_flow;
                end

                % total_rel_flowを更新
                total_rel_flow = total_rel_flow + route.rel_flow;
            end

            % inflowを更新
            inflow = inflow + tmp_inflow * target_rel_flow / total_rel_flow;
        end

        % inflow_ratesを取得
        inflow_rate = inflow / obj.cycle_time;

        % PhaseInflowRateMapを更新（指数移動平均）
        obj.PhaseInflowRateMap(obj.current_phase_id) = (1-obj.alpha) * obj.PhaseInflowRateMap(obj.current_phase_id) + obj.alpha * inflow_rate;
         
    elseif strcmp(property_name, 'PhaseOutflowRateMap')
        % outflowを初期化
        outflow = 0;

        % 現在のフェーズによって更新部分に必要なIDが異なるため、分岐処理を行う
        if obj.Roads.count() == 4
            if obj.current_phase_id == 1
                road_ids = [1, 3];
            elseif obj.current_phase_id == 2
                road_ids = [1, 3];
            elseif obj.current_phase_id == 3
                road_ids = [2, 4];
            elseif obj.current_phase_id == 4
                road_ids = [2, 4];
            else
                error('current_phase_id is invalid.');
            end
        elseif obj.Roads.count() == 3
            error('Not implemented yet.');
        else
            error('Not defined number of roads.');
        end

        % Roadクラスを走査
        for road_id = road_ids
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % RoadクラスからPhaseOutflowMapを取得
            PhaseOutflowMap = Road.get('PhaseOutflowMap');

            % outflowsを更新
            outflow = outflow + PhaseOutflowMap(obj.current_phase_id);
        end

        % outflow_rateを取得
        outflow_rate = outflow / obj.cycle_time;

        % PhaseOutflowRateMapを更新（指数移動平均）
        obj.PhaseOutflowRateMap(obj.current_phase_id) = (1-obj.beta) * obj.PhaseOutflowRateMap(obj.current_phase_id) + obj.beta * outflow_rate;
    elseif strcmp(property_name, 'next_split_start')
        % 次のフェーズIDを取得
        if obj.current_phase_id < obj.num_phases
            next_phase_id = obj.current_phase_id + 1;
        else
            next_phase_id = 1;
        end

        % 飽和度を比較して次のフェーズの方が飽和度が高い場合前倒しする
        if obj.PhaseSaturationMap(obj.current_phase_id) < obj.PhaseSaturationMap(next_phase_id)
            % nest_split_startを更新
            obj.next_split_start = obj.PhaseSplitStartMap(next_phase_id) - obj.delta_s;

            % PhaseSplitStartMapを更新
            obj.PhaseSplitStartMap(next_phase_id) = obj.PhaseSplitStartMap(obj.current_phase_id) - 1;
        else
            % next_split_startを更新
            obj.next_split_start = obj.PhaseSplitStartMap(next_phase_id);
        end
    elseif strcmp(property_name, 'cycle_time')
        % up_or_downを初期化
        up_or_down = 'down';

        % 飽和度が0.9以上のフェーズが存在するか走査
        for phase_id = 1: obj.num_phases
            if obj.PhaseSaturationMap(phase_id) >= 0.9
                up_or_down = 'up';
            end
        end

        % 変化量を取得
        if obj.cycle_time <= 64
            delta = obj.delta_c;
        elseif obj.cycle_time <= 128
            delta = 2 * obj.delta_c;
        else
            delta = 4 * obj.delta_c;
        end

        % up_or_downによって処理を分岐
        if strcmp(up_or_down, 'up')
            obj.cycle_time = obj.cycle_time + delta;
        elseif strcmp(up_or_down, 'down')
            obj.cycle_time = obj.cycle_time - delta;
        else
            error('up_or_down is invalid.');
        end

        % フェーズを走査
        for order_id = 1: obj.num_phases
            % フェーズIDを取得
            phase_id = mod(obj.current_phase_id + order_id, obj.num_phases);

            % 0になってしまった場合、num_phasesに変更
            if phase_id == 0
                phase_id = obj.num_phases;
            end

            % PhaseSplitStartMapを更新
            if strcmp(up_or_down, 'up')
                obj.PhaseSplitStartMap(phase_id) = obj.PhaseSplitStartMap(phase_id) + order_id * delta / obj.num_phases;
            elseif strcmp(up_or_down, 'down')
                obj.PhaseSplitStartMap(phase_id) = obj.PhaseSplitStartMap(phase_id) - order_id * delta / obj.num_phases;
            else
                error('up_or_down is invalid.');
            end
        end
    elseif strcmp(property_name, 'current_phase_id')
        % 現在のフェーズIDを更新
        obj.current_phase_id = obj.next_phase_id;
        
    elseif strcmp(property_name, 'next_phase_id')
        % 次のフェーズIDを更新
        if obj.next_phase_id < obj.num_phases
            obj.next_phase_id = obj.next_phase_id + 1;
        else
            obj.next_phase_id = 1;
        end
    else
        error('Property name is invalid.');
    end
end