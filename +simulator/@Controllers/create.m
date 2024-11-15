function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Intersectionsクラスを取得
        Intersections = obj.Network.get('Intersections');

        % 交差点の個数分だけ走査
        for intersection_id = Intersections.getKeys()
            % Intersectionクラスを取得
            Intersection = Intersections.itemByKey(intersection_id);

            % Controllerクラスを作成
            Controller = simulator.Controller(obj, obj.count() + 1, Intersection);

            % Controllerクラスに手法を設定
            Controller.create('Method');

            % ElementsにControllerをプッシュ
            obj.add(Controller);
        end
    else
        error('Property name is invalid.');
    end
end