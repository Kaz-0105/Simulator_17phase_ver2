function update(obj, property_name)
    if strcmp(property_name, 'Intersections')
        % Intersectionクラスを走査
        for intersection_id = 1: obj.Intersections.count()
            % Intersectionクラスを取得
            Intersection = obj.Intersections.itemByKey(intersection_id);

            % IntersectionクラスにRoadsを作成
            Intersection.create('Roads');
        end

    elseif strcmp(property_name, 'Roads')
        % Roadクラスを走査
        for road_id = 1: obj.Roads.count()
            % Roadクラスを取得
            Road = obj.Roads.itemByKey(road_id);

            % RoadクラスにIntersectionを作成
            Road.create('Intersections');
        end
    else
        error('error: Property name is invalid.');
    end
end