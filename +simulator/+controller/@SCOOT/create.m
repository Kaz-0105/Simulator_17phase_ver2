function create(obj, property_name)
    if  strcmp(property_name, 'num_phases')
        % 道路の数を取得
        num_roads = obj.Roads.count();

        % num_roadsで場合分け
        if num_roads == 3
            obj.num_phases = 3;
        elseif num_roads == 4
            obj.num_phases = 4;
        else
            error('Not defined number of roads.');
        end

        % delta_cの初期化
        obj.delta_c = obj.num_phases;

    elseif strcmp(property_name, 'PhaseSplitStartMap')
        % PhaseSplitMapの初期化
        obj.PhaseSplitStartMap = containers.Map('KeyType', 'double', 'ValueType', 'double');

        % バリデーションを行う
        if mod(obj.cycle_time, obj.num_phases) ~= 0
            error('Cycle time is not divisible by the number of phases.');
        end

        % 道路の数で場合分け
        if obj.num_phases == 3
            % PhaseSplitStartMapの要素を追加
            obj.PhaseSplitStartMap(1) = obj.current_time + obj.cycle_time;
            obj.PhaseSplitStartMap(2) = obj.current_time + obj.cycle_time / 3;
            obj.PhaseSplitStartMap(3) = obj.current_time + obj.cycle_time / 3 * 2;
        elseif obj.num_phases == 4
            % PhaseSplitStartMapの要素を追加
            obj.PhaseSplitStartMap(1) = obj.current_time + obj.cycle_time;
            obj.PhaseSplitStartMap(2) = obj.current_time + obj.cycle_time / 4;
            obj.PhaseSplitStartMap(3) = obj.current_time + obj.cycle_time / 4 * 2;
            obj.PhaseSplitStartMap(4) = obj.current_time + obj.cycle_time / 4 * 3;
        else
            error('num_phases is invalid.');
        end
        
    elseif strcmp(property_name, 'PhaseSaturationMap')
        % PhaseSaturationRateMapの初期化
        obj.PhaseSaturationMap = containers.Map('KeyType', 'int32', 'ValueType', 'double');

        % フェーズを走査
        for phase_id = 1: obj.num_phases
            % フェーズの飽和率を初期化
            obj.PhaseSaturationMap(phase_id) = 0;
        end
    elseif strcmp(property_name, 'PhaseInflowRateMap')
        % PhaseInflowRateMapの初期化
        obj.PhaseInflowRateMap = containers.Map('KeyType', 'int32', 'ValueType', 'double');

        % フェーズを走査
        for phase_id = 1: obj.num_phases
            % フェーズの流入率を初期化
            obj.PhaseInflowRateMap(phase_id) = 0;
        end
    elseif strcmp(property_name, 'PhaseOutflowRateMap')
        % PhaseOutflowRateMapの初期化
        obj.PhaseOutflowRateMap = containers.Map('KeyType', 'int32', 'ValueType', 'double');

        % フェーズを走査
        for phase_id = 1: obj.num_phases
            % フェーズの流出率を初期化
            obj.PhaseOutflowRateMap(phase_id) = 0.125;
        end
    elseif strcmp(property_name, 'PhaseSignalGroupsMap')
        % PhaseSignalGroupsMapを初期化
        PhaseSignalGroupsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % SignalGroupsを取得
        SignalGroups = obj.Intersection.get('SignalController').get('SignalGroups');

        % OrderGroupMapを取得
        OrderGroupMap = obj.Intersection.get('SignalController').get('OrderGroupMap');

        % Roadsクラスを取得
        Roads = obj.Intersection.get('Roads');

        if Roads.input.count() == 4
            % PhaseSignalGroupsMapを設定
            PhaseSignalGroupsMap(1) = [1, 2, 7, 8];
            PhaseSignalGroupsMap(2) = [3, 9];
            PhaseSignalGroupsMap(3) = [4, 5, 10, 11];
            PhaseSignalGroupsMap(4) = [6, 12];
        elseif Roads.input.count() == 3
            % PhaseSignalGroupsMapを設定
            PhaseSignalGroupsMap(1) = [1, 2, 5];
            PhaseSignalGroupsMap(2) = [3, 4];
            PhaseSignalGroupsMap(3) = 6;
        else
            error('error: Not defined number of roads.');
        end

        % フェーズを走査
        for phase_id = 1: PhaseSignalGroupsMap.Count()
            % signal_group_ordersを取得
            signal_group_orders = PhaseSignalGroupsMap(phase_id);

            % TmpSignalGroupsを初期化
            TmpSignalGroups = simulator.network.SignalGroups(obj.Intersection);

            % orderを走査
            for signal_group_order = signal_group_orders
                % signal_group_idを取得
                signal_group_id = OrderGroupMap(signal_group_order);

                % SignalGroupを取得
                SignalGroup = SignalGroups.itemByKey(signal_group_id);

                % SignalGroupをTmpSignalGroupsにプッシュ
                TmpSignalGroups.add(SignalGroup, signal_group_order);
            end

            % TmpSignalGroupsをPhaseSignalGroupsMapにプッシュ
            PhaseSignalGroupsMap(phase_id) = TmpSignalGroups;
        end

        % IntersectionクラスにPhaseSignalGroupsMapを設定
        obj.Intersection.set('PhaseSignalGroupsMap', PhaseSignalGroupsMap);
    else
        error('Property name is invalid.');
    end
end