function update(obj, property_name , varargin)
    if strcmp(property_name, 'skip_flag')
        obj.skip_flag = true;
        obj.objectives = [];

        if obj.Timer.get('current_time') + obj.split_change_width + obj.yellow_time + obj.red_time == obj.next_split_start
            if ~obj.split_adjusted_flag
                obj.skip_flag = false;
                obj.objectives = [obj.objectives, "split"];
            end
        end

        if obj.Timer.get('current_time') + 1 == obj.next_cycle_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "cycle"];
        end

        if obj.Timer.get('current_time') == obj.next_split_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "split_change"];
        end

        if obj.Timer.get('current_time') == obj.next_cycle_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "cycle_change"];
        end

        if obj.Timer.get('current_time') + obj.yellow_time + obj.red_time == obj.next_split_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "yellow"];
        end

        if obj.Timer.get('current_time') + obj.red_time == obj.next_split_start
            obj.skip_flag = false;
            obj.objectives = [obj.objectives, "red"];
        end

    elseif strcmp(property_name, 'PhaseSaturationMap')
        
        % inflow_rata, outflow_rateを取得
        inflow_rate = obj.PhaseInflowRateMap(obj.phase_ids(1));
        outflow_rate = obj.PhaseOutflowRateMap(obj.phase_ids(1));

        % PhaseSaturationMapを更新
        if outflow_rate == 0
            obj.PhaseSaturationMap(obj.phase_ids(1)) = 0;
        else
            obj.PhaseSaturationMap(obj.phase_ids(1)) = inflow_rate / outflow_rate;
        end
        
    elseif strcmp(property_name, 'PhaseInflowRateMap')
        % inflowを初期化
        inflow = 0;

        % 現在のフェーズによって更新部分に必要なIDが異なるため、分岐処理を行う
        if obj.Roads.count() == 4
            if obj.phase_ids(1) == 1
                road_ids = [1, 3];
                orders = [1, 2];
            elseif obj.phase_ids(1) == 2
                road_ids = [1, 3];
                orders = 3;
            elseif obj.phase_ids(1) == 3
                road_ids = [2, 4];
                orders = [1, 2];
            elseif obj.phase_ids(1) == 4
                road_ids = [2, 4];
                orders = 3;
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

            % VehicleRoutesクラスを取得
            VehicleRoutes = Road.get('VehicleRoutingDecision').get('VehicleRoutes');

            % VeicleRouteクラスを走査
            for vehicle_route_id = VehicleRoutes.getKeys()
                % VehicleRouteクラスを取得
                VehicleRoute = VehicleRoutes.itemByKey(vehicle_route_id);

                % orderを取得
                order = VehicleRoute.get('order');

                % rel_flowを取得
                rel_flow = VehicleRoute.get('rel_flow');

                % orderがordersに含まれる場合
                if ismember(order, orders)
                    % target_rel_flowを更新
                    target_rel_flow = target_rel_flow + rel_flow;
                end

                % total_rel_flowを更新
                total_rel_flow = total_rel_flow + rel_flow;
            end

            % inflowを更新
            inflow = inflow + tmp_inflow * target_rel_flow / total_rel_flow;
        end

        % amplify_rateを取得（計算するタイミングがフェーズの途中であるため）
        amplify_rate = obj.cycle_time / (obj.cycle_time - obj.next_split_start + obj.Timer.get('current_time'));

        % inflow_ratesを取得
        inflow_rate = inflow / obj.cycle_time * amplify_rate;

        % PhaseInflowRateMapを更新（指数移動平均）
        obj.PhaseInflowRateMap(obj.phase_ids(1)) = (1-obj.alpha) * obj.PhaseInflowRateMap(obj.phase_ids(1)) + obj.alpha * inflow_rate;
         
    elseif strcmp(property_name, 'PhaseOutflowRateMap')
        % outflowを初期化
        outflow = 0;

        % 現在のフェーズによって更新部分に必要なIDが異なるため、分岐処理を行う
        if obj.Roads.count() == 4
            if obj.phase_ids(1) == 1
                road_ids = [1, 3];
            elseif obj.phase_ids(1) == 2
                road_ids = [1, 3];
            elseif obj.phase_ids(1) == 3
                road_ids = [2, 4];
            elseif obj.phase_ids(1) == 4
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
            outflow = outflow + PhaseOutflowMap(obj.phase_ids(1));
        end

        % amplify_rateを取得（計算するタイミングがフェーズの途中であるため）
        amplify_rate = (obj.next_split_start - obj.current_split_start) / (obj.Timer.get('current_time') - obj.current_split_start);

        % outflow_rateを取得
        outflow_rate = outflow / obj.cycle_time * amplify_rate;

        % PhaseOutflowRateMapを更新（指数移動平均）
        obj.PhaseOutflowRateMap(obj.phase_ids(1)) = (1-obj.beta) * obj.PhaseOutflowRateMap(obj.phase_ids(1)) + obj.beta * outflow_rate;
    
    elseif strcmp(property_name, 'next_split_start')
        % 引数の数をバリデーション
        if nargin ~= 3
            error('The number of input arguments is invalid.');
        end

        % objectiveを取得
        objective = varargin{1};

        % objectiveによって処理を分岐
        if strcmp(objective, 'split')
            % 前後のフェーズの飽和度を比較し分岐
            if obj.PhaseSaturationMap(obj.phase_ids(1)) < obj.PhaseSaturationMap(obj.phase_ids(2))  
                % スプリットの長さが変更後に最小の連続時間を確保できるかどうかで場合分け
                if obj.PhaseSplitStartMap(obj.phase_ids(2)) - obj.current_split_start  < obj.min_cycle + obj.split_change_width
                    % next_split_startを更新
                    obj.next_split_start = obj.current_split_start + obj.min_cycle;
                else
                    % next_split_startを更新
                    obj.next_split_start = obj.next_split_start - obj.split_change_width;

                    % 現在のフェーズを黄色信号に変更
                    obj.Intersection.run(obj.phase_ids(1), 'yellow');
                end

                % 最小の連続時間を確保できるとき
                if obj.PhaseSplitStartMap(obj.phase_ids(2)) - obj.current_split_start >= obj.min_cycle + 1
                    % PhaseSplitStartMapを更新
                    obj.PhaseSplitStartMap(obj.phase_ids(2)) = obj.PhaseSplitStartMap(obj.phase_ids(2)) - 1;
                end

            elseif obj.PhaseSaturationMap(obj.phase_ids(1)) > obj.PhaseSaturationMap(obj.phase_ids(2))
                % スプリットの長さが変更後に最小の連続時間を確保できるかどうかで場合分け
                if obj.PhaseSplitStartMap(obj.phase_ids(3)) - obj.PhaseSplitStartMap(obj.phase_ids(2)) < obj.min_cycle + obj.split_change_width
                    % next_split_startを更新
                    obj.next_split_start = obj.PhaseSplitStartMap(obj.phase_ids(3)) - obj.min_cycle;
                else
                    % next_split_startを更新
                    obj.next_split_start = obj.next_split_start + obj.split_change_width;
                end

                % PhaseSplitStartMapを更新
                if obj.PhaseSplitStartMap(obj.phase_ids(3)) - obj.PhaseSplitStartMap(obj.phase_ids(2)) >= obj.min_cycle + 1
                    obj.PhaseSplitStartMap(obj.phase_ids(2)) = obj.PhaseSplitStartMap(obj.phase_ids(2)) + 1;
                end
            end

            % split_adjusted_flagを更新
            obj.split_adjusted_flag = true;

        elseif strcmp(objective, 'split_change')
            % next_split_startを更新
            obj.next_split_start = obj.PhaseSplitStartMap(obj.phase_ids(2));

            % split_adjusted_flagを更新
            obj.split_adjusted_flag = false;

        else
            error('Objective is invalid.');
        end
        
    elseif strcmp(property_name, 'cycle_time')
        % cycle_change_typeを初期化
        cycle_change_type = 'down';

        % 飽和度の平均と最大値を与えるフェーズIDを初期化
        average_saturation = 0;
        max_saturation_phase_id = NaN;

        % PhaseSaturationMapを走査
        for phase_id = 1: obj.num_phases
            % 飽和度の平均を更新
            average_saturation = average_saturation + obj.PhaseSaturationMap(phase_id) / obj.num_phases;

            % 状態で場合分け
            if isnan(max_saturation_phase_id)
                % 飽和度の最大値を与えるフェーズIDを更新
                max_saturation_phase_id = phase_id;

            elseif obj.PhaseSaturationMap(phase_id) > obj.PhaseSaturationMap(max_saturation_phase_id)
                % 飽和度の最大値を与えるフェーズIDを更新
                max_saturation_phase_id = phase_id;

            end
        end

        % 飽和度の平均が1を超えたとき
        if average_saturation >= 1
            cycle_change_type = 'up';
        end

        for phase_id = 1: obj.num_phases
            if obj.PhaseSaturationMap(phase_id) > obj.emergency_threshold
                cycle_change_type = 'emergency_up';
            end
        end

        % 変更できなかったフェーズをカウント
        count = 0;

        % emergency_upの場合に使用するフラグを初期化
        if strcmp(cycle_change_type, 'emergency_up')
            found_flag = false;
        end

        % フェーズを走査
        for order = 1: obj.num_phases
            % フェーズIDを取得
            phase_id = mod(obj.phase_ids(1) + order, obj.num_phases);

            % 0になってしまった場合、num_phasesに変更
            if phase_id == 0
                phase_id = obj.num_phases;
            end

            % PhaseSplitStartMapを更新
            if strcmp(cycle_change_type, 'up')
                % PhaseSplitStartMapを更新
                obj.PhaseSplitStartMap(phase_id) = obj.PhaseSplitStartMap(phase_id) + (order-1);

            elseif strcmp(cycle_change_type, 'down')
                % スプリットの長さが10秒より大きいかどうかで場合分け
                if order == 1
                    if obj.PhaseSplitStartMap(phase_id) + obj.cycle_time - obj.PhaseSplitStartMap(obj.phase_ids(end)) <= obj.min_cycle
                        % 変更できなかったフェーズ数をカウント
                        count = count + 1;
                    end
                else
                    if obj.PhaseSplitStartMap(phase_id) - obj.PhaseSplitStartMap(obj.phase_ids(end)) <= obj.min_cycle
                        % 変更できなかったフェーズ数をカウント
                        count = count + 1;
                    end

                    % PhaseSplitStartMapを更新
                    obj.PhaseSplitStartMap(phase_id) = obj.PhaseSplitStartMap(phase_id) - (order - 1 - count);
                end
            elseif strcmp(property_name, 'emergency_up')
                % PhaseSplitStartMapを更新
                if found_flag == false
                    if phase_id ~= max_saturation_phase_id + 1
                        continue;
                    end

                    % PhaseSplitStartMapを更新
                    obj.PhaseSplitStartMap(phase_id) = obj.PhaseSplitStartMap(phase_id) + obj.cycle_change_width;

                    % found_flagを更新
                    found_flag = true;
                else
                    % PhaseSplitStartMapを更新
                    obj.PhaseSplitStartMap(phase_id) = obj.PhaseSplitStartMap(phase_id) + obj.cycle_change_width;
                end
            else
                error('cycle_change_type is invalid.');
            end
        end

        % cycle_change_typeによって処理を分岐
        if strcmp(cycle_change_type, 'up') || strcmp(cycle_change_type, 'emergency_up')
            % cycle_timeを更新
            obj.cycle_time = obj.cycle_time + obj.cycle_change_width;
        elseif strcmp(cycle_change_type, 'down')
            % cycle_timeを更新
            obj.cycle_time = obj.cycle_time - obj.cycle_change_width + count;
        else
            error('cycle_change_type is invalid.');
        end
        
    elseif strcmp(property_name, 'current_split_start')
        % current_split_startを更新
        obj.current_split_start = obj.next_split_start;

        % PhaseSplitStartMapを更新
        obj.PhaseSplitStartMap(obj.phase_ids(2)) = obj.PhaseSplitStartMap(obj.phase_ids(2)) + obj.cycle_time;

    elseif strcmp(property_name, 'current_cycle_start')
        % current_cycle_startを更新
        obj.current_cycle_start = obj.next_cycle_start;

    elseif strcmp(property_name, 'next_cycle_start')
        % next_cycle_startを更新
        obj.next_cycle_start = obj.next_cycle_start + obj.cycle_time;
        
    else
        error('Property name is invalid.');
    end
end