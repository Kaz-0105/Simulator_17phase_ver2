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
    else
        error('Field:update', 'Invalid property name');
    end
end