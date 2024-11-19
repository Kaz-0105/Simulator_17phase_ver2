function update(obj, property_name)    
    if strcmp(property_name, 'SignalGroup')
        % PhaseSignalGroupsMapを取得
        PhaseSignalGroupsMap = obj.SignalController.get('PhaseSignalGroupsMap');

        % フェーズを走査
        for phase_id = cell2mat(PhaseSignalGroupsMap.keys())
            % フェーズIDが1のときはスキップ
            if phase_id == 1
                continue;
            end
            
            % 信号の色を変更
            obj.SignalController.run(phase_id, 'red');
        end

        % フェーズIDが1のとき
        obj.SignalController.run(1, 'green');
        
    elseif strcmp(property_name, 'Evaluation')
        % queue_tableが存在するとき
        if obj.record_flags.queue_length
            % queue_tableの更新
            obj.update('queue_table');
        end

        % delay_tableが存在するとき
        if obj.record_flags.delay_time
            % delay_tableの更新
            obj.update('delay_table');
        end

    elseif strcmp(property_name, 'queue_table')
        % average_queue_lengthとmax_queue_lengthを初期化
        obj.average_queue_length = 0;
        obj.max_queue_length = 0;

        % num_roadsを取得
        num_roads = obj.Roads.input.count();

        % Roadクラスを走査
        for road_id = obj.Roads.input.getKeys()
            % Roadクラスを取得
            Road = obj.Roads.input.itemByKey(road_id);

            % average_queue_lengthとmax_queue_lengthを更新
            obj.average_queue_length = obj.average_queue_length + Road.get('QueueCounters').get('average_queue_length') / num_roads;
            obj.max_queue_length = max(obj.max_queue_length, Road.get('QueueCounters').get('max_queue_length'));
        end

        % queue_tableを更新
        obj.queue_table(end + 1, :) = {obj.Timer.get('current_time'), obj.average_queue_length, obj.max_queue_length};

    elseif strcmp(property_name, 'delay_table')
        % average_delay_timeとmax_delay_timeを初期化
        obj.average_delay_time = 0;
        obj.max_delay_time = 0;

        % num_roadsを取得
        num_roads = obj.Roads.input.count();

        % Roadクラスを走査
        for road_id = obj.Roads.input.getKeys()
            % Roadクラスを取得
            Road = obj.Roads.input.itemByKey(road_id);

            % average_delay_timeとmax_delay_timeを更新
            obj.average_delay_time = obj.average_delay_time + Road.get('DelayMeasurements').get('average_delay_time') / num_roads;
            obj.max_delay_time = max(obj.max_delay_time, Road.get('DelayMeasurements').get('max_delay_time'));
        end

        % delay_tableを更新
        obj.delay_table(end + 1, :) = {obj.Timer.get('current_time'), obj.average_delay_time, obj.max_delay_time};
    else
        error('Property name is invalid.');
    end
end