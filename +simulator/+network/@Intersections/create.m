function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');
        
        % Intersectionsクラス用の設定を取得
        network = obj.Config.get('network');
        intersections = network.intersections;

        % IntersectionsMapを取得
        IntersectionsMap = intersections.IntersectionsMap;

        for intersection_id = cell2mat(IntersectionsMap.keys())
            % intersection_structを取得
            intersection_struct = IntersectionsMap(intersection_id);

            % Intersectionクラスを作成
            Intersection = simulator.network.Intersection(obj);
            Intersection.set('id', intersection_struct.id);
            Intersection.set('method', intersection_struct.method);

            % Elementsにintersectionをプッシュ
            obj.Elements(Intersection.get('id')) = Intersection;
        end
    else
        error('Property name is invalid.');
    end
end