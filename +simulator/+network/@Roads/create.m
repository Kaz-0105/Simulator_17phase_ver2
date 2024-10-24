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