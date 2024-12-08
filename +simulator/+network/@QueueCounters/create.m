function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VissimのCOMオブジェクトを設定
        obj.set('Vissim', Net.QueueCounters); 
    elseif strcmp(property_name, 'Elements')
        % QueueCounterを走査
        for signal_head_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % QueueCounterクラスを作成
            QueueCounter = simulator.network.QueueCounter(obj, signal_head_id);

            % ElementsにQueueCounterをプッシュ
            obj.add(QueueCounter);
        end
    elseif strcmp(property_name, 'queue_table')
        % record_flagsを取得
        record_flags = obj.Road.get('record_flags');

        % record_flags.queue_lengthがtrueの場合
        if record_flags.queue_length
            % queue_tableを作成
            variable_names = {'time', 'queue_length', 'max_queue_length'};
            variable_types = {'double', 'double', 'double'};
            variable_size = [0, 3];
            obj.set('queue_table', table('Size', variable_size,'VariableNames', variable_names, 'VariableTypes', variable_types));
            
            % average_queue_lengthとmax_queue_lengthを初期化
            obj.set('queue_length', 0);
            obj.set('max_queue_length', 0);
        end
    else
        error('Property name is not a valid class');
    end
end