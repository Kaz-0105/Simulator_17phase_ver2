function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Networkクラスを取得
        Network = obj.Intersections.get('Network');

        % current_timeを更新
        obj.current_time = Network.get('current_time');
        
    elseif strcmp(property_name, 'SignalGroup')
        % フェーズを走査
        for phase_id = cell2mat(obj.PhaseSignalGroupsMap.keys())
            if phase_id == 1
                obj.run(phase_id, 'green');
            else
                obj.run(phase_id, 'red');
            end
        end
    else
        error('Property name is invalid.');
    end
end