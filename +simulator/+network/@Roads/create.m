function create(obj, property_name, type)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

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
                    Road = Roads.itemByKey(input_road.id);

                    % ElementsにRoadをプッシュ
                    obj.Elements(input_road.road_id) = Road;
                end
            elseif strcmp(obj.type, 'output')   
                % 流出道路を走査
                for output_road = intersection_struct.output_roads
                    % Roadクラスを取得
                    Road = Roads.itemByKey(output_road.id);

                    % ElementsにRoadをプッシュ
                    obj.Elements(output_road.road_id) = Road;
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
    else
        error('Property name is invalid.');
    end
end