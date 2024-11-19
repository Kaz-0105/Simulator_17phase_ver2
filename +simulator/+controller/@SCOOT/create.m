function create(obj, property_name)
    if  strcmp(property_name, 'num_phases')
        % PhaseSignalGroupsMapを取得
        PhaseSignalGroupsMap = obj.Intersection.get('SignalController').get('PhaseSignalGroupsMap');

        % num_phasesを設定
        obj.num_phases = double(PhaseSignalGroupsMap.Count);

    elseif strcmp(property_name, 'PhaseSplitStartMap')
        % PhaseSplitMapの初期化
        obj.PhaseSplitStartMap = containers.Map('KeyType', 'double', 'ValueType', 'double');

        % バリデーションを行う
        if mod(int64(obj.cycle_time), obj.num_phases) ~= 0
            error('Cycle time is not divisible by the number of phases.');
        end

        % フェーズを走査
        for phase_id = 1: obj.num_phases
            if phase_id == 1
                obj.PhaseSplitStartMap(phase_id) = obj.Timer.get('current_time') + obj.cycle_time;
            else
                obj.PhaseSplitStartMap(phase_id) = obj.Timer.get('current_time') + obj.cycle_time / obj.num_phases * (phase_id - 1);
            end
        end
        
    elseif strcmp(property_name, 'PhaseSaturationMap')
        % PhaseSaturationRateMapの初期化
        obj.PhaseSaturationMap = containers.Map('KeyType', 'int64', 'ValueType', 'double');

        % フェーズを走査
        for phase_id = 1: obj.num_phases
            % フェーズの飽和率を初期化
            obj.PhaseSaturationMap(phase_id) = 0;
        end
    elseif strcmp(property_name, 'PhaseInflowRateMap')
        % PhaseInflowRateMapの初期化
        obj.PhaseInflowRateMap = containers.Map('KeyType', 'int64', 'ValueType', 'double');

        % フェーズを走査
        for phase_id = 1: obj.num_phases
            % フェーズの流入率を初期化
            obj.PhaseInflowRateMap(phase_id) = 0;
        end
    elseif strcmp(property_name, 'PhaseOutflowRateMap')
        % PhaseOutflowRateMapの初期化
        obj.PhaseOutflowRateMap = containers.Map('KeyType', 'int64', 'ValueType', 'double');

        % フェーズを走査
        for phase_id = 1: obj.num_phases
            % フェーズの流出率を初期化
            obj.PhaseOutflowRateMap(phase_id) = 0.125;
        end
    else
        error('Property name is invalid.');
    end
end