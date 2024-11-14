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
    elseif strcmp(property_name, 'DataCollections')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % DataCollectionsを取得
            DataCollections = Road.get('DataCollections');
            data_collections = Road.get('data_collections');
            
            % DataCollectionMeasurementsに要素が存在しない場合削除
            if DataCollections.input.count() == 0
                DataCollections = rmfield(DataCollections, 'input');
                data_collections = rmfield(data_collections, 'input');
            end

            if DataCollections.output.count() == 0
                DataCollections = rmfield(DataCollections, 'output');
                data_collections = rmfield(data_collections, 'output');
            end

            % DataCollectionsを更新
            Road.set('DataCollections', DataCollections);
            Road.set('data_collections', data_collections);

        end
    else
        error('Property name is invalid.');
    end
end