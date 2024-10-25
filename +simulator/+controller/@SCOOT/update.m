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

    elseif strcmp(property_name, 'PhaseSaturationRateMap')

    else
        error('Property name is invalid.');
    end
end