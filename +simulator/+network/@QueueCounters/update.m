function update(obj, property_name)
    if strcmp(property_name, 'queue_table')
        % 要素クラスを走査
        for queue_counter_id = obj.getKeys()
            % QueueCounterクラスを取得
            QueueCounter = obj.itemByKey(queue_counter_id);

            % QueueCounterクラスのupdateメソッドを実行
            QueueCounter.update('queue_table');
        end

        % average_queue_lengthとmax_queue_lengthを初期化
        obj.average_queue_length = 0;
        obj.max_queue_length = 0;

        % 要素クラスを走査
        for queue_counter_id = obj.getKeys()
            % QueueCounterクラスを取得
            QueueCounter = obj.itemByKey(queue_counter_id);

            % average_queue_lengthとmax_queue_lengthを更新
            obj.average_queue_length = obj.average_queue_length + QueueCounter.get('queue_length')/obj.count();
            obj.max_queue_length = max(obj.max_queue_length, QueueCounter.get('queue_length'));
        end

        % queue_tableにプッシュ
        obj.queue_table(end + 1, :) = {obj.Timer.get('current_time'), obj.average_queue_length, obj.max_queue_length};
    else
        error('property_name is invalid');
    end

end