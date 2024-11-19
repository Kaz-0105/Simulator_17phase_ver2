function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを設定
        obj.Vissim = obj.QueueCounters.get('Vissim').ItemByKey(obj.id);

    elseif strcmp(property_name, 'Road')
        % link_idを取得
        link_id = obj.Vissim.Link.get('AttValue', 'No');

        % Linkクラスを設定
        Links = obj.QueueCounters.get('Network').get('Links');
        obj.Link = Links.itemByKey(link_id);

        % Roadクラスを設定
        obj.Road = obj.Link.get('Road');

        % queue_counter構造体の作成
        queue_counter.id = obj.id;
        queue_counter.type = obj.Link.get('type');

        % queue_counterをRoadクラスにプッシュ
        queue_counters = obj.Road.get('queue_counters');
        obj.Road.set('queue_counters', [queue_counters, queue_counter]);

        % RoadクラスにQueueCounterクラスをプッシュ
        obj.Road.get('QueueCounters').add(obj);

    elseif strcmp(property_name, 'queue_table')
        % record_flagsを取得
        record_flags = obj.Road.get('record_flags');

        % record_flags.queue_lengthがtrueの場合
        if record_flags.queue_length
            % queue_tableを作成
            variable_names = {'time', 'queue_length'};
            variable_types = {'double', 'double'};
            variable_size = [0, 2];
            obj.set('queue_table', table('Size', variable_size,'VariableNames', variable_names, 'VariableTypes', variable_types));

            % queue_lengthを初期化
            obj.set('queue_length', 0);
        end
    else
        error('Property name is not a valid class');
    end   
end