function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Networkクラスを取得
        Network = obj.Intersections.get('Network');

        % current_timeを更新
        obj.current_time = Network.get('current_time');
        
    elseif strcmp(property_name, 'SignalGroup')
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
        if isprop(obj, 'queue_table')
            % queue_tableの更新
            obj.update('queue_table');
        end

        % delay_tableが存在するとき
        if isprop(obj, 'delay_table')
            % delay_tableの更新
            obj.update('delay_table');
        end

    elseif strcmp(property_name, 'queue_table')
        % average_queue_lengthとmax_queue_lengthを初期化
        average_queue_length = 0;
        max_queue_length = 0;

        % road_counterを初期化
        road_counter = 0;

        % Roadクラスを走査
        for road_id = obj.Roads.input.getKeys()
            % Roadクラスを取得
            Road = obj.Roads.input.itemByKey(road_id);

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

    elseif strcmp(property_name, 'delay_table')
        % average_delayとmax_delayを初期化
        average_delay = 0;
        max_delay = 0;

        % counterを初期化
        counter = 0;

        % Roadクラスを走査
        for road_id = 1 : obj.Roads.input.count()
            % Roadクラスを取得
            Road = obj.Roads.input.itemByKey(road_id);

            % delay_tableを取得
            delay_table = Road.get('delay_table');

            % 最後のレコードを取得
            delay_record = delay_table(end, :);

            % average_delayを更新
            for route_id = 1: width(delay_record) - 1
                % counterをインクリメント
                counter = counter + 1;

                % average_delayを更新
                average_delay = average_delay + (delay_record{1, 1 + route_id} - average_delay) / counter;

                % max_delayを更新
                max_delay = max(max_delay, delay_record{1, 1 + route_id});
            end
        end

        % delay_tableを更新
        obj.delay_table(end + 1, :) = {obj.current_time, average_delay, max_delay};
    else
        error('Property name is invalid.');
    end
end