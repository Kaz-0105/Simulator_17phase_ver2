function delete(obj, property_name)
    if strcmp(property_name, 'QueueCounters')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);
            
            % QueueCountersに要素が存在しない場合削除
            if isempty(Road.get('queue_counters'))
                Road.delete('QueueCounters');
                Road.delete('queue_counters');
            end
        end
    elseif strcmp(property_name, 'SignalHeads')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);
            
            % SignalHeadsに要素が存在しない場合削除
            if isempty(Road.get('signal_heads'))
                Road.delete('SignalHeads');
                Road.delete('signal_heads');
            end
        end
    elseif strcmp(property_name, 'DelayMeasurements')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);
            
            % DelayMeasurementsに要素が存在しない場合削除
            if isempty(Road.get('delay_measurements'))
                Road.delete('DelayMeasurements');
                Road.delete('delay_measurements');
            end
        end
    else
        error('Property name is invalid.');
    end
end