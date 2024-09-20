function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % Intersectionsクラスを取得
        Intersections = obj.Field.get('Intersections');

        % 交差点の個数分だけ走査
        for intersection_id = 1: Intersections.count()
        end
    else
        error('Property name is invalid.');
    end
end