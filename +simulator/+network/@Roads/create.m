function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Roadsクラス用の設定を取得
        network = obj.Config.get('network');
        roads = network.roads;

        % RoadsMapを取得
        RoadsMap = roads.RoadsMap;

        for road_id = cell2mat(RoadsMap.keys())
            % road_structを取得
            road_struct = RoadsMap(road_id);

            % Roadクラスを作成
            Road = simulator.network.Road(obj, road_struct);

            % Elementsにroadをプッシュ
            obj.add(Road);
        end

        % DataCollectionsの設定
        % obj.create('DataCollections');

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

            % Intersectionクラス、Roads構造体を取得
            Intersection = StartRoad.get('Intersections').output;
            Roads = Intersection.get('Roads');

            % InputRoadを走査
            for road_order_id = 1: Roads.input.count()
                % InputRoadクラスを取得
                InputRoad = Roads.input.itemByKey(road_order_id);

                % input_road_idを取得
                input_road_id = InputRoad.get('id');

                % input_road_idとstart_road_idが一致したとき
                if input_road_id == start_road_id
                    input_road_order_id = road_order_id;
                    break;
                end
            end

            % OutputRoadを走査
            for road_order_id = 1: Roads.output.count()
                % OutputRoadクラスを取得
                OutputRoad = Roads.output.itemByKey(road_order_id);

                % OutputRoadのIDを取得
                output_road_id = OutputRoad.get('id');

                % output_road_idとto_road_idが一致したとき
                if output_road_id == to_road_id
                    output_road_order_id = road_order_id;
                    break;
                end
            end

            % num_roadsを取得
            num_roads = Roads.input.count();

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
                    % Intersectionクラスを取得
                    Intersection = Road.get('Intersection').output;

                    % Roads構造体を取得
                    Roads = Intersection.get('Roads');

                    % num_roadsを取得
                    num_roads = Roads.input.count();

                    % names, types, sizeを初期化
                    names = {'time'};
                    types = {'double'};
                    size = [0, 1];

                    % route_idを走査
                    for route_id = 1: (num_roads-1)
                        % 新しいコラム名を作成
                        name = sprintf('route_%d', route_id);

                        % names, types, sizeに追加
                        names{1, end+1} = name;
                        types{1, end+1} = 'double';
                        size(2) = size(2) + 1;
                    end

                    % delay_tableを初期化
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
    elseif strcmp(property_name, 'LinkRoadMap')
        obj.set('LinkRoadMap', containers.Map('KeyType', 'int32', 'ValueType', 'int32'));   
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % Linksを取得
            Links = Road.get('Links');

            % Linkクラスを走査
            for link_id = Links.getKeys()
                % LinkRoadMapにプッシュ
                obj.LinkRoadMap(link_id) = road_id;
            end

            % Connectorsが存在するとき
            if isfield(Road, 'Connectors')
                % Connectorsを取得
                Connectors = Road.get('Connectors');

                % Connectorsを走査
                for link_id = Connectors.getKeys()
                    % LinkRoadMapにプッシュ
                    obj.LinkRoadMap(link_id) = road_id;
                end
            end
        end


    elseif strcmp(property_name, 'VehicleRoutingDecision')
        % VehicleRoutingDecisionsクラスを取得
        VehicleRoutingDecisions = obj.Network.get('VehicleRoutingDecisions');

        % VehicleRoutingDecisionを走査
        for vehicle_routing_decision_id = VehicleRoutingDecisions.getKeys()
            % VehicleRoutingDecisionクラスを取得
            VehicleRoutingDecision = VehicleRoutingDecisions.itemByKey(vehicle_routing_decision_id);

            % link_idを取得
            link_id = VehicleRoutingDecision.get('link_id');

            % Roadクラスを取得
            Road = obj.itemByKey(obj.LinkRoadMap(link_id));

            % RoadクラスにVehicleRoutingDecisionをセット
            Road.set('VehicleRoutingDecision', VehicleRoutingDecision);
            VehicleRoutingDecision.set('Road', Road);
        end

    elseif strcmp(property_name, 'DataCollections')
        % DataCollectionMeasurementsを取得
        DataCollections = obj.get('Network').get('DataCollections');

        % Linksを取得
        Links = obj.get('Network').get('Links');

        % DataCollectionMeasurementsを走査
        for measurement_id = DataCollections.getKeys()
            % DataCollectionクラスを取得
            DataCollection = DataCollections.itemByKey(measurement_id);

            % link_idを取得
            link_id = DataCollection.get('link_id');

            Link = Links.itemByKey(link_id);

            % Linkがコネクタのとき
            if strcmp(Link.get('class'), 'link')
                % Roadクラスを取得
                Road = obj.itemByKey(obj.LinkRoadMap(link_id));

                % 流入道路か流出道路かで分岐
                if isprop(Road, 'VehicleRoutingDecision')
                    Road.DataCollections.input.add(obj, Road.DataCollections.input.count() + 1);
                else
                    Road.DataCollections.output.add(obj, Road.DataCollections.output.count() + 1);
                end
            elseif strcmp(link.get('class'), 'connector')
                % from_link_idを取得
                from_link_id = DataCollection.get('from_link_id');

                % Roadクラスを取得
                Road = obj.itemByKey(obj.LinkRoadMap(from_link_id));

                % DataCollectionsにプッシュ
                Road.DataCollections.output.add(obj, Road.DataCollections.output.count() + 1);
            else
                error('Link class is invalid.');
            end
        end
    
        
    else
        error('Property name is invalid.');
    end
end