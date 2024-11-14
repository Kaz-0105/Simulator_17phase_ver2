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
    else
        error('Property name is invalid.');
    end
end