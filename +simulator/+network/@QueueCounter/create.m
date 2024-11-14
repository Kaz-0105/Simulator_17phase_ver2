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
        Roads = obj.QueueCounters.get('Network').get('Roads');
        LinkRoadMap = Roads.get('LinkRoadMap');
        obj.Road = Roads.itemByKey(LinkRoadMap(link_id));

        % queue_counter構造体の作成
        queue_counter.id = obj.id;
        queue_counter.type = obj.Link.get('type');

        % queue_counterをRoadクラスにプッシュ
        queue_counters = obj.Road.get('queue_counters');
        obj.Road.set('queue_counters', [queue_counters, queue_counter]);

        % RoadクラスにQueueCounterクラスをプッシュ
        obj.Road.get('QueueCounters').add(obj);
    else
        error('Property name is not a valid class');
    end   
end