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
            obj.PhaseSplitStartMap(2) = obj.current_time + obj.cycle_time / 3;
            obj.PhaseSplitStartMap(3) = obj.current_time + obj.cycle_time / 3 * 2;
            obj.PhaseSplitStartMap(1) = obj.current_time + obj.cycle_time;
        elseif obj.num_phases == 4
            % PhaseSplitStartMapの要素を追加
            obj.PhaseSplitStartMap(2) = obj.current_time + obj.cycle_time / 4;
            obj.PhaseSplitStartMap(3) = obj.current_time + obj.cycle_time / 4 * 2;
            obj.PhaseSplitStartMap(4) = obj.current_time + obj.cycle_time / 4 * 3;
            obj.PhaseSplitStartMap(1) = obj.current_time + obj.cycle_time;
        else
            error('num_phases is invalid.');
        end
    elseif strcmp(property_name, 'cycle_start_time')
        % Simulatorクラスからcurrent_timeを取得
        Controllers = obj.Controller.get('Controllers');
        Simulator = Controllers.get('Simulator');

        % current_timeを取得
        obj.current_time = Simulator.get('current_time');
        obj.cycle_start_time = obj.current_time;

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
    else
        error('Property name is invalid.');
    end
end