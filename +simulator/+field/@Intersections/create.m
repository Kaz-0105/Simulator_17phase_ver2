function create(obj, property_name, type)
    if strcmp(property_name, 'Elements')
        if type == 1
            % Elementsを初期化
            obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

            % Intersectionsクラス用の設定を取得
            intersections = obj.Config.get('intersections');

            for intersection = intersections
                % Intersectionクラスを作成
                Intersection = simulator.field.Intersection(obj);
                Intersection.set('id', intersection.id);

                % Elementsにintersectionをプッシュ
                obj.Elements(intersection.id) = Intersection;
            end
        elseif type == 2
        else
            error('Type is invalid.');
        end
    else
        error('Property name is invalid.');
    end
end