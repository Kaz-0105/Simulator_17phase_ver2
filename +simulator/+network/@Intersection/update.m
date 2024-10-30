function update(obj, property_name)
    if strcmp(property_name, 'SignalGroup')
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