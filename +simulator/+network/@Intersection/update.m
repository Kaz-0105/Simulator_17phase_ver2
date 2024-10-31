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
    elseif strcmp(property_name, 'Evaluation')
        % queue_tableが存在するとき
        if isprop(obj, 'queue_table')
            % queue_tableの更新
            obj.update('queue_table');
        end

    elseif strcmp(property_name, 'queue_table')
        % average_queue_lengthとmax_queue_lengthを初期化
        average_queue_length = 0;
        max_queue_length = 0;

        % road_counterを初期化
        road_counter = 0;

        % Roadクラスを走査
        for road_id = obj.InputRoads.getKeys()
            % Roadクラスを取得
            Road = obj.InputRoads.itemByKey(road_id);

            % queue_tableを取得
            queue_table = Road.get('queue_table');

            % 最後のレコードを取得
            queue_record = queue_table(end, :);

            % road_counterを更新
            road_counter = road_counter + 1;

            % average_queue_lengthを更新
            average_queue_length = average_queue_length + (queue_record.average - average_queue_length) / road_counter;

            % max_queue_lengthを更新
            max_queue_length = max(max_queue_length, queue_record.max);
        end

        % queue_tableを更新
        obj.queue_table(end + 1, :) = {obj.current_time, average_queue_length, max_queue_length};

    else
        error('Property name is invalid.');
    end
end