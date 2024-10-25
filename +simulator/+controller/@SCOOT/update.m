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

        if obj.current_time + obj.delta_s + 1 == next_split_start
            obj.skip_flag = false;

            if obj.current_time + 1 == obj.cycle_start_time + obj.cycle_time
                obj.objective = 'both';
            else
                obj.objective = 'split';
            end
        elseif obj.current_time + 1 == obj.cycle_start_time + obj.cycle_time
            obj.skip_flag = false;
            obj.objective = 'cycle';
        else
            obj.skip_flag = true;
        end

    elseif strcmp(property_name, 'PhaseSaturationMap')
        % phase_idを走査
        for phase_id = 1: obj.num_phases
            % inflow_rata, outflow_rateを取得
            inflow_rate = obj.PhaseInflowRateMap(phase_id);
            outflow_rate = obj.PhaseOutflowRateMap(phase_id);

            % saturation_rateを計算
            saturation_rate = inflow_rate / outflow_rate;

            % PhaseSaturationMapを更新
            obj.PhaseSaturationMap(phase_id) = saturation_rate;
        end
    elseif strcmp(property_name, 'PhaseInflowRateMap')
        if obj.Roads.count() == 4
            % inflowを初期化
            inflow = 0;

            % road_idsとorder_idsを設定
            if obj.current_phase_id == 1
                % road_ids : 北＆南、order_ids : 左折＆直進
                road_ids = [1, 3];
                order_ids = [1, 2];
            elseif obj.current_phase_id == 2
                % road_ids : 北＆南、order_ids : 右折
                road_ids = [1, 3];
                order_ids = 3;
            elseif obj.current_phase_id == 3
                % road_ids : 東＆西、order_ids : 左折＆直進
                road_ids = [2, 4];
                order_ids = [1, 2];
            elseif obj.current_phase_id == 4
                % road_ids : 東＆西、order_ids : 右折
                road_ids = [2, 4];
                order_ids = 3;
            else
                error('current_phase_id is invalid.');
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

                % rel_flowを初期化
                rel_flow = 0;

                % routesを取得
                routes = Road.get('routing_decision').routes;

                % RoutesMapとRouteOrderMapを取得
                RoutesMap = routes.RoutesMap;
                RouteOrderMap = routes.RouteOrderMap;

                % sumを初期化
                sum = 0;

                % routeを走査
                for route_id = 1: RoutesMap.Count()
                    % routeを取得
                    route = RoutesMap(route_id);

                    % tmp_rel_flowを取得
                    tmp_rel_flow = route.rel_flow;

                    % order_idを取得
                    order_id = RouteOrderMap(route_id);

                    % order_idで場合分け
                    if ismember(order_id, order_ids)
                        rel_flow = rel_flow + tmp_rel_flow;
                    end

                    % sumを更新
                    sum = sum + tmp_rel_flow;
                end

                % inflowを更新
                inflow = inflow + tmp_inflow * rel_flow / sum;
            end

            % inflow_ratesを取得
            inflow_rate = inflow / obj.cycle_time;

            % PhaseInflowRateMapを更新
            obj.PhaseInflowRateMap(obj.current_phase_id) = (1-obj.alpha) * obj.PhaseInflowRateMap(obj.current_phase_id) + obj.alpha * inflow_rate;

        elseif obj.Roads.count() == 3
            error('Not implemented yet.');
        else
            error('Not defined number of roads.');
        end
         
    elseif strcmp(property_name, 'PhaseOutflowRateMap')
        % outflowsを初期化
        outflows = zeros(1, obj.num_phases);

        % Roadクラスを走査
        for road_id = 1 : obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % tmp_outflowを初期化
            tmp_outflow = zeros(1, obj.num_phases);

            % RoadクラスからPhaseOutflowMapを取得
            PhaseOutflowMap = Road.get('PhaseOutflowMap');

            % phase_idを走査
            for phase_id = 1 : PhaseOutflowMap.Count()
                tmp_outflow(phase_id) = PhaseOutflowMap(phase_id);
            end

            % outflowsを更新
            outflows = outflows + tmp_outflow;
        end

        % outflow_ratesを取得
        outflow_rates = outflows / obj.cycle_time;

        % PhaseOutflowRateMapを更新（指数移動平均）
        for phase_id = 1 : obj.num_phases
            obj.PhaseOutflowRateMap(phase_id) = (1-obj.beta) * obj.PhaseOutflowRateMap(phase_id) + obj.beta * outflow_rates(phase_id);
        end
    else
        error('Property name is invalid.');
    end
end