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
                Road.create('links');

                % Elementsにroadをプッシュ
                obj.Elements(Road.get('id')) = Road;
            end

            % RoutingDecisionの設定
            obj.create('routing_decisions');
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
    else
        error('Property name is invalid.');
    end
end