function create(obj, property_name)
    if strcmp(property_name, 'record_flags')
        % Networkクラスを取得
        Network = obj.Intersections.get('Network');

        % record_flagsを取得
        obj.record_flags = Network.get('record_flags');

    elseif strcmp(property_name, 'queue_table')
        % record_flagがtrueのとき
        if obj.record_flags.queue_length
            % queue_tableを初期化
            names = {'time', 'average_queue_length', 'max_queue_length'};
            types = {'double', 'double', 'double'};
            variable_size = [0, 3];
            queue_table = table('Size', variable_size, 'VariableNames', names, 'VariableTypes', types);

            % queue_tableを設定
            obj.set('queue_table', queue_table);

            % average_queue_length, max_queue_lengthを初期化
            obj.set('average_queue_length', 0);
            obj.set('max_queue_length', 0);
        end

    elseif strcmp(property_name, 'delay_table')
        % record_flagがtrueのとき
        if obj.record_flags.delay_time
            % delay_tableを初期化
            names = {'time', 'average_delay_time', 'max_delay_time'};
            types = {'double', 'double', 'double'};
            variable_size = [0, 3];
            delay_table = table('Size', variable_size, 'VariableNames', names, 'VariableTypes', types);

            % delay_tableを設定
            obj.set('delay_table', delay_table);

            % average_delay_time, max_delay_timeを初期化
            obj.set('average_delay_time', 0);
            obj.set('max_delay_time', 0);
        end
        
    elseif strcmp(property_name, 'Roads')
        % Roadsクラスを作成
        obj.Roads.input = simulator.network.Roads(obj);
        obj.Roads.output = simulator.network.Roads(obj);

        % Roadsクラスを取得
        Roads = obj.Intersections.get('Network').get('Roads');

        % 流入道路を走査
        for input_road = obj.intersection_struct.input_roads
            % Roadクラスを取得
            Road = Roads.itemByKey(input_road.road_id);

            % RoadクラスにSignalHeads, DelayMeasurements, QueueCountersをセット
            Road.create('SignalHeads');
            Road.create('DelayMeasurements');
            Road.create('QueueCounters');

            % ElementsにRoadをプッシュ
            obj.Roads.input.add(Road, input_road.id);

            % RoadクラスにIntersectionをセット
            Intersections = Road.get('Intersections');
            Intersections.output = obj;
            Road.set('Intersections', Intersections);
        end

        % 流出道路を走査
        for output_road = obj.intersection_struct.output_roads
            % Roadクラスを取得
            Road = Roads.itemByKey(output_road.road_id);

            % ElementsにRoadをプッシュ
            obj.Roads.output.add(Road, output_road.id);

            % RoadクラスにIntersectionをセット
            Intersections = Road.get('Intersections');
            Intersections.input = obj;
            Road.set('Intersections', Intersections);
        end
    
    elseif strcmp(property_name, 'RoadOrderMap')
        % RoadOrderMapを初期化
        obj.set('RoadOrderMap', containers.Map('KeyType', 'double', 'ValueType', 'double'));

        % 流入道路を走査
        for order = obj.Roads.input.getKeys()
            % Roadクラスを取得
            Road = obj.Roads.input.itemByKey(order);
            
            % road_idを取得
            road_id = Road.get('id');
            
            % RoadOrderMapに追加
            obj.RoadOrderMap(road_id) = order;
        end

        % 流出道路を走査
        for order = obj.Roads.output.getKeys()
            % Roadクラスを取得
            Road = obj.Roads.output.itemByKey(order);
            
            % road_idを取得
            road_id = Road.get('id');
            
            % RoadOrderMapに追加
            obj.RoadOrderMap(road_id) = order;
        end
    
    else
        error('error: Property name is invalid.');
    end
end