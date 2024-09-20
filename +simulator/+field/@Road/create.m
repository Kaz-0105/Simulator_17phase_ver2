function create(obj, property_name)
    if strcmp(property_name, 'Intersections')
        % Intersectionsクラスを取得
        Intersections = obj.Roads.get('Intersections');

        % Intersectionクラスを走査
        for intersection_id = 1: Intersections.count()
            Intersection = Intersections.itemByKey(intersection_id);

            % InputRoadsクラスを取得
            InputRoads = Intersection.get('InputRoads');

            for input_road_id = InputRoads.getKeys()
                if input_road_id == obj.id
                    % プロパティにOutputIntersectionクラスを追加
                    prop = addprop(obj, 'OutputIntersection');
                    prop.SetAccess = 'public';
                    prop.GetAccess = 'public';

                    % OutputIntersectionクラスを設定
                    obj.OutputIntersection = Intersection;
                end
            end

            % OutputRoadsクラスを取得
            OutputRoads = Intersection.get('OutputRoads');

            for output_road_id = OutputRoads.getKeys()
                if output_road_id == obj.id
                    % プロパティにInputIntersectionクラスを追加
                    prop = addprop(obj, 'InputIntersection');
                    prop.SetAccess = 'public';
                    prop.GetAccess = 'public';

                    % InputIntersectionクラスを設定
                    obj.InputIntersection = Intersection;
                end
            end
        end
    else
        error('error: Property name is invalid.');
    end
end