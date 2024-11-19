function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Intersectionsクラス用の設定を取得
        network = obj.Config.get('network');
        intersections = network.intersections;

        % IntersectionsMapを取得
        IntersectionsMap = intersections.IntersectionsMap;

        for intersection_id = cell2mat(IntersectionsMap.keys())
            % intersection_structを取得
            intersection_struct = IntersectionsMap(intersection_id);

            % Intersectionクラスを作成
            Intersection = simulator.network.Intersection(obj, intersection_struct);

            % Elementsにintersectionをプッシュ
            obj.add(Intersection);
        end

    elseif strcmp(property_name, 'Roads')
        % Intersectionクラスを走査
        for intersection_id = 1: obj.count()
            % Intersectionクラスを取得
            Intersection = obj.itemByKey(intersection_id);

            % IntersectionクラスにRoadsを作成
            Intersection.create('Roads');
        end
    else
        error('Property name is invalid.');
    end
end