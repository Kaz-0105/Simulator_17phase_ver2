function create(obj, property_name, type)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % 上位層のクラスがFieldかIntersectionかで分岐
        if strcmp(type, 'Field')
            % Roadsクラス用の設定を取得
            roads = obj.Config.get('roads');

            for road = roads
                % Roadクラスを作成
                Road = simulator.field.Road(obj);
                Road.set('id', road.id);

                % Elementsにroadをプッシュ
                obj.Elements(road.id) = Road;
            end
        elseif strcmp(type, 'Intersection')
            % IntersectionクラスのIDを取得
            intersection_id = obj.Intersection.get('id');

            % Intersectionクラス用の設定を取得
            intersections = obj.Config.get('intersections');

            % 対象の交差点の構造体を取得
            intersection = intersections(intersection_id);

            % 全体のRoadsクラスを取得
            Intersections = obj.Intersection.get('Intersections');
            Roads = Intersections.get('Roads');

            if strcmp(obj.type, 'input')
                % 流入道路を走査
                for input_road = intersection.input_roads
                    % Roadクラスを取得
                    Road = Roads.itemByKey(input_road.id);

                    % ElementsにRoadをプッシュ
                    obj.Elements(input_road.road_id) = Road;
                end
            elseif strcmp(obj.type, 'output')   
                % 流出道路を走査
                for output_road = intersection.output_roads
                    % Roadクラスを取得
                    Road = Roads.itemByKey(output_road.id);

                    % ElementsにRoadをプッシュ
                    obj.Elements(output_road.road_id) = Road;
                end
            end
        else
            error('Type is invalid.');
        end 
    else
        error('Property name is invalid.');
    end
end