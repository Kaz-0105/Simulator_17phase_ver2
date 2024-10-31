function create(obj, property_name, type)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'double', 'ValueType', 'any');

        % 上位層のクラスがNetworkかIntersectionかで分岐
        if strcmp(type, 'Network')
            % Roadsクラス用の設定を取得
            network = obj.Config.get('network');
            roads = network.roads;

            % RoadsMapを取得
            RoadsMap = roads.RoadsMap;

            for road_id = cell2mat(RoadsMap.keys())
                % road_structを取得
                road_struct = RoadsMap(road_id);

                % Roadクラスを作成
                Road = simulator.network.Road(obj);
                Road.set('id', road_struct.id);
                Road.set('links', road_struct.links);

                % links, speed, inflowsのプロパティの作成
                Road.create('links');
                Road.create('speed');
                Road.create('inflows');

                % Elementsにroadをプッシュ
                obj.Elements(Road.get('id')) = Road;
            end

            % RoutingDecisionの設定
            obj.create('routing_decisions');

            % DataCollectionsの設定
            obj.create('DataCollections');

        elseif strcmp(type, 'Intersection')
            % IntersectionクラスのIDを取得
            intersection_id = obj.Intersection.get('id');

            % Intersectionクラス用の設定を取得
            network = obj.Config.get('network');
            intersections = network.intersections;

            % IntersectionsMapを取得
            IntersectionsMap = intersections.IntersectionsMap;

            % 対象の交差点の構造体を取得
            intersection_struct = IntersectionsMap(intersection_id);

            % 全体のRoadsクラスを取得
            Intersections = obj.Intersection.get('Intersections');
            Roads = Intersections.get('Roads');

            if strcmp(obj.type, 'input')
                % 流入道路を走査
                for input_road = intersection_struct.input_roads
                    % Roadクラスを取得
                    Road = Roads.itemByKey(input_road.road_id);

                    % ElementsにRoadをプッシュ
                    obj.Elements(input_road.id) = Road;
                end
            elseif strcmp(obj.type, 'output')   
                % 流出道路を走査
                for output_road = intersection_struct.output_roads
                    % Roadクラスを取得
                    Road = Roads.itemByKey(output_road.road_id);

                    % ElementsにRoadをプッシュ
                    obj.Elements(output_road.id) = Road;
                end
            end
        else
            error('Type is invalid.');
        end

    elseif strcmp(property_name, 'SignalHeads')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % RoadクラスにVissimのSignalHeadオブジェクトをセット
            Road.create('SignalHead');
        end
    elseif strcmp(property_name, 'QueueCounters')
        % LinkQueueCounterMapの初期化
        LinkQueueCounterMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % NetwrokクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % QueueCountersのComオブジェクトを取得
        QueueCounters = Net.QueueCounters;

        % QueueCounterの走査
        for QueueCounter = QueueCounters.GetAll()'
            % セルから取り出し
            QueueCounter = QueueCounter{1};

            % queue_counter構造体を取得
            queue_counter = struct();
            queue_counter.id = QueueCounter.get('AttValue', 'No');
            queue_counter.Vissim = QueueCounter;

            % LinkのComオブジェクトを取得
            Link = QueueCounter.Link;

            % LinkのIDを取得
            link_id = Link.get('AttValue', 'No');

            % LinkQueueCounterMapにプッシュ
            LinkQueueCounterMap(link_id) = queue_counter;
        end

        % QueueCounterが存在するリンク群を取得
        target_link_ids = cell2mat(LinkQueueCounterMap.keys());

        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % links構造体を取得
            links = Road.get('links');

            % queue_counters構造体の初期化
            queue_counters = struct();

            % メインリンクのIDを取得
            main_link_id = links.main.id;

            % main_link_idがtarget_link_idsに含まれているとき
            if ismember(main_link_id, target_link_ids)
                % queue_counter構造体を取得
                queue_counter = LinkQueueCounterMap(main_link_id);

                % queue_countersにプッシュ
                queue_counters.main = queue_counter;
            end

            % 分岐が存在するとき
            if isfield(links, 'branch')
                % branchの方向を走査
                for direction = ["left", "right"]
                    % char型に変換
                    direction = char(direction);

                    % その方向の分岐があるとき
                    if isfield(links.branch, direction)
                        % branch構造体を取得
                        branch = links.branch.(direction);

                        % サブリンクのIDを取得
                        sub_link_id = branch.link.id;

                        % sub_link_idがtarget_link_idsに含まれているとき
                        if ismember(sub_link_id, target_link_ids)
                            % queue_counter構造体を取得
                            queue_counter = LinkQueueCounterMap(sub_link_id);

                            % queue_countersにプッシュ
                            queue_counters.branch.(direction) = queue_counter;
                        end
                    end
                end
            end

            % record_flagがtrueのとき
            if Road.get('record_flags').queue_length
                % queue_countersが空でないとき
                if ~isempty(fieldnames(queue_counters))
                    % Roadクラスにqueue_countersをセット
                    Road.set('queue_counters', queue_counters);

                    % queue_tableを初期化
                    names = {'time', 'average', 'max'};
                    types = {'double', 'double', 'double'};
                    size = [0, 3];
                    queue_table = table('Size', size, 'VariableTypes', types, 'VariableNames', names);


                    % Roadクラスにqueue_tableをセット
                    Road.set('queue_table', queue_table);
                end
            end
        end
    elseif strcmp(property_name, 'DelayMeasurements')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % TravelDelayMapの初期化
        TravelDelayMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % DelayMeasurementsのComオブジェクトを取得
        DelayMeasurements = Net.DelayMeasurements;

        % DelayMeasurementの走査
        for DelayMeasurement = DelayMeasurements.GetAll()'
            % セルから取り出し
            DelayMeasurement = DelayMeasurement{1};

            % IDを取得
            delay_id = DelayMeasurement.get('AttValue', 'No');

            % TravelTimeMeasurementsのComオブジェクトを取得
            TravelTimeMeasurements = DelayMeasurement.VehTravTmMeas;

            % travel_idsを初期化
            travel_ids = [];

            % TravelTimeMeasurementの走査
            for TravelTimeMeasurement = TravelTimeMeasurements.GetAll()'
                % セルから取り出し
                TravelTimeMeasurement = TravelTimeMeasurement{1};

                % IDを取得
                travel_id = TravelTimeMeasurement.get('AttValue', 'No');

                % travel_idsにプッシュ
                travel_ids = [travel_ids, travel_id];
            end

            % travel_idsの数をバリデーション
            if length(travel_ids) ~= 1
                error('Please establish a one-to-one relationship between DelayMeasurement and TravelTimeMeasurement in Vissim GUI.');
            end

            % TravelDelayMapに追加
            TravelDelayMap(delay_id) = travel_ids;
        end

        % VehicleTravelTimeMeasurementsのComオブジェクトを取得
        TravelTimeMeasurements = Net.VehicleTravelTimeMeasurements;

        % MainLinkRoadMapの初期化
        MainLinkRoadMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % main_link_idを取得
            main_link_id = Road.get('links').main.id;

            % MainLinkRoadMapに追加
            MainLinkRoadMap(main_link_id) = road_id;
        end

        % RoadTravelsMap、TravelRouteMapの初期化
        RoadTravelsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
        TravelRouteMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % VehicleTravelTimeMeasurementを走査
        for TravelTimeMeasurement = TravelTimeMeasurements.GetAll()'
            % セルから取り出し
            TravelTimeMeasurement = TravelTimeMeasurement{1};

            % travel_idを取得
            travel_id = TravelTimeMeasurement.get('AttValue', 'No');

            % StartLink、EndLinkのComオブジェクトを取得
            StartLink = TravelTimeMeasurement.StartLink;
            EndLink = TravelTimeMeasurement.EndLink;

            % ToLinkのComオブジェクトを取得
            ToLink = EndLink.ToLink;

            % StartLinkとToLinkのIDを取得
            start_link_id = StartLink.get('AttValue', 'No');
            to_link_id = ToLink.get('AttValue', 'No');

            % start_road_idとto_road_idを取得
            start_road_id = MainLinkRoadMap(start_link_id);
            to_road_id = MainLinkRoadMap(to_link_id);

            % RoadTravelsMapに追加
            if isKey(RoadTravelsMap, start_road_id)
                RoadTravelsMap(start_road_id) = [RoadTravelsMap(start_road_id), travel_id];
            else
                RoadTravelsMap(start_road_id) = travel_id;
            end

            % StartRoadクラスを取得
            StartRoad = obj.itemByKey(start_road_id);

            % Intersectionクラス、InputRoadsクラス、OutputRoadsクラスを取得
            Intersection = StartRoad.get('OutputIntersection');
            InputRoads = Intersection.get('InputRoads');
            OutputRoads = Intersection.get('OutputRoads');

            % InputRoadを走査
            for road_order_id = 1: InputRoads.count()
                % InputRoadクラスを取得
                InputRoad = InputRoads.itemByKey(road_order_id);

                % input_road_idを取得
                input_road_id = InputRoad.get('id');

                % input_road_idとstart_road_idが一致したとき
                if input_road_id == start_road_id
                    input_road_order_id = road_order_id;
                    break;
                end
            end

            % OutputRoadを走査
            for road_order_id = 1: OutputRoads.count()
                % OutputRoadクラスを取得
                OutputRoad = OutputRoads.itemByKey(road_order_id);

                % OutputRoadのIDを取得
                output_road_id = OutputRoad.get('id');

                % output_road_idとto_road_idが一致したとき
                if output_road_id == to_road_id
                    output_road_order_id = road_order_id;
                    break;
                end
            end

            % num_roadsを取得
            num_roads = InputRoads.count();

            % route_order_idを走査
            for route_order_id = 1: (num_roads-1)
                if mod(input_road_order_id + route_order_id - output_road_order_id, num_roads) == 0
                    break;
                end
            end

            % TravelRouteMapに追加
            TravelRouteMap(travel_id) = route_order_id;
        end

        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % road_idを取得
            road_id = Road.get('id');

            % RoadTravelsMapにキーが存在するとき
            if isKey(RoadTravelsMap, road_id)
                % travel_idsを取得
                travel_ids = RoadTravelsMap(road_id);

                % delay_measurements構造体を初期化
                delay_measurements = [];

                % travel_idを走査
                for travel_id = travel_ids
                    % delay_measurement構造体を初期化
                    delay_measurement = struct();

                    % delay_idを取得
                    delay_measurement.id = TravelDelayMap(travel_id);

                    % TravelRouteMapからroute_idを取得
                    delay_measurement.route_id = TravelRouteMap(travel_id);

                    % delay_MeasurementのComオブジェクトを取得
                    delay_measurement.Vissim = DelayMeasurements.ItemByKey(delay_measurement.id);

                    % delay_measurementsにプッシュ
                    delay_measurements = [delay_measurements, delay_measurement];
                end

                % Roadクラスにdelay_measurementsをセット
                Road.set('delay_measurements', delay_measurements);

                % record_flagがtrueのとき
                if Road.get('record_flags').delay_time
                    % delay_tableを初期化
                    names = {'time', 'average', 'max'};
                    types = {'double', 'double', 'double'};
                    size = [0, 3];
                    delay_table = table('Size', size, 'VariableTypes', types, 'VariableNames', names);

                    % Roadクラスにdelay_tableをセット
                    Road.set('delay_table', delay_table);
                end
            end
        end

    elseif strcmp(property_name, 'Intersections')
        % Roadクラスを走査
        for road_id = 1: obj.count()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % RoadクラスにIntersectionを作成
            Road.create('Intersections');
        end

        % routesの設定
        obj.create('routes');
    elseif strcmp(property_name, 'routing_decisions')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % RoutingDecisionsのComオブジェクトを取得
        RoutingDecisions = Net.VehicleRoutingDecisionsStatic;

        % RoutingDecisionの走査
        for RoutingDecision = RoutingDecisions.GetAll()'
            % セルから取り出し
            RoutingDecision = RoutingDecision{1};

            % link_idを取得
            link_id = RoutingDecision.Link.get('AttValue', 'No');

            % Roadクラスを走査
            for road_id = obj.getKeys()
                % Roadクラスを取得
                Road = obj.itemByKey(road_id);

                % main_link_idを取得
                main_link_id = Road.get('links').main.id;

                % link_idとmain_link_idが一致した場合
                if link_id == main_link_id
                    % routing_decision構造体を作成
                    routing_decision = struct();
                    routing_decision.id = RoutingDecision.get('AttValue', 'No');
                    routing_decision.Vissim = RoutingDecision;

                    % RoadクラスにRoutingDecisionをセット
                    Road.set('routing_decision', routing_decision);
                end
            end
        end
    elseif strcmp(property_name, 'routes')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % routing_decisionのプロパティが存在するとき
            if isprop(Road, 'routing_decision')
                Road.create('routes');
            end
        end
    elseif strcmp(property_name, 'DataCollections')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            if isprop(Road, 'routing_decision')
                % InputDataCollectionsMapとOutputDataCollectionsMapの初期化
                InputDataCollectionsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
                OutputDataCollectionsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');

                % RoadクラスにInputDataCollectionsMapとOutputDataCollectionsMapをセット
                Road.set('InputDataCollectionsMap', InputDataCollectionsMap);
                Road.set('OutputDataCollectionsMap', OutputDataCollectionsMap);
            else
                % InputDataCollectionsMapとOutputDataCollectionsMapの初期化
                OutputDataCollectionsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');

                % RoadクラスにInputDataCollectionsMapとOutputDataCollectionsMapをセット
                Road.set('OutputDataCollectionsMap', OutputDataCollectionsMap);
            end
        end

        % MeasurementPointMapの初期化
        MeasurementPointMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % DataCollectionMeasurementsのComオブジェクトを取得
        Net = obj.Network.get('Vissim');
        DataCollectionMeasurements = Net.DataCollectionMeasurements;

        % DataCollectionMeasurementの走査
        for DataCollectionMeasurement = DataCollectionMeasurements.GetAll()'
            % セルから取り出し
            DataCollectionMeasurement = DataCollectionMeasurement{1};

            % IDを取得
            measurement_id = DataCollectionMeasurement.get('AttValue', 'No');

            % DataCollectionPointsのComオブジェクトを取得
            DataCollectionPoints = DataCollectionMeasurement.DataCollectionPoints;

            % DataCollectionPointsの要素の数が１になっているかバリデーション
            if DataCollectionPoints.Count() ~= 1
                error('DataCollectionPoints.Count() is invalid.');
            end

            % DataCollectionPointのComオブジェクトを取得
            DataCollectionPoint = DataCollectionPoints.GetAll();
            DataCollectionPoint = DataCollectionPoint{1};

            % IDを取得
            point_id = DataCollectionPoint.get('AttValue', 'No');

            % MeasurementPointMapに追加
            MeasurementPointMap(point_id) = measurement_id;
        end

        % DataCollectionMeasurementsのComオブジェクトを取得
        Net = obj.Network.get('Vissim');
        DataCollectionPoints = Net.DataCollectionPoints;

        % DataCollectionPointの走査
        for DataCollectionPoint = DataCollectionPoints.GetAll()'
            % セルから取り出し
            DataCollectionPoint = DataCollectionPoint{1};

            % IDを取得
            point_id = DataCollectionPoint.get('AttValue', 'No');

            % LinkのComオブジェクトを取得
            Link = DataCollectionPoint.Lane.Link;

            % LinkのIDを取得
            link_id = Link.get('AttValue', 'No');

            if link_id < 10000
                for road_id = obj.getKeys()
                    % Roadクラスを取得
                    Road = obj.itemByKey(road_id);

                    % links構造体の取得
                    links = Road.get('links');

                    % メインリンクと比較
                    if link_id == links.main.id
                        % 流出口かどうかで分岐
                        if isprop(Road, 'routing_decision')
                            DataCollectionsMap = Road.get('InputDataCollectionsMap');
                        else
                            DataCollectionsMap = Road.get('OutputDataCollectionsMap');
                        end

                        % measurement_idを取得
                        measurement_id = MeasurementPointMap(point_id);

                        % DataCollectionsMapに追加
                        DataCollectionsMap(measurement_id) = DataCollectionMeasurements.ItemByKey(measurement_id);

                        % 処理を抜ける
                        break;
                    end
                end

                % 処理を抜ける
                continue;
            end

            % 1つ前のLinkを取得
            Link = Link.FromLink;

            % LinkのIDを取得
            link_id = Link.get('AttValue', 'No');

            % Roadクラスを走査
            for road_id = obj.getKeys()
                % Roadクラスを取得
                Road = obj.itemByKey(road_id);

                % links構造体の取得
                links = Road.get('links');

                % メインリンクと比較
                if link_id == links.main.id
                    % OutputDataCollectionsMapを取得
                    OutputDataCollectionsMap = Road.get('OutputDataCollectionsMap');

                    % measurement_idを取得
                    measurement_id = MeasurementPointMap(point_id);

                    % OutputDataCollectionsMapに追加
                    OutputDataCollectionsMap(measurement_id) = DataCollectionMeasurements.ItemByKey(measurement_id);

                    % 処理を抜ける
                    break;
                end

                % サブリンクがあるとき
                if isfield(links, 'branch')
                    % stop_flagの初期化
                    stop_flag = false;

                    % branchの方向を走査
                    for direction = ["left", "right"]
                        % char型に変換
                        direction = char(direction);

                        % その方向の分岐があるとき
                        if isfield(links.branch, direction)
                            % branch構造体を取得
                            branch = links.branch.(direction);

                            % サブリンクとの比較
                            if link_id == branch.link.id
                                % OutputDataCollectionsMapを取得
                                OutputDataCollectionsMap = Road.get('OutputDataCollectionsMap');

                                % measurement_idを取得
                                measurement_id = MeasurementPointMap(point_id);

                                % OutputDataCollectionsMapに追加
                                OutputDataCollectionsMap(measurement_id) = DataCollectionMeasurements.ItemByKey(measurement_id);

                                % 処理を抜ける
                                stop_flag = true;
                            end
                        end
                    end

                    % 処理を抜ける
                    if stop_flag
                        break;
                    end
                end
            end
        end
    else
        error('Property name is invalid.');
    end
end