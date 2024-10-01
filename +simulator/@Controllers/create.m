function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'double', 'ValueType', 'any');

        % Intersectionsクラスを取得
        Intersections = obj.Network.get('Intersections');

        % 交差点の個数分だけ走査
        for intersection_id = Intersections.getKeys()
            % Intersectionクラスを取得
            Intersection = Intersections.itemByKey(intersection_id);

            % Controllerクラスを作成
            Controller = simulator.Controller(obj);

            % ControllerクラスとIntersectionクラスを紐付け
            Controller.set('Intersection', Intersection);
            Intersection.set('Controller', Controller);

            % 交差点の制御方式によって場合分け
            method = Intersection.get('method');

            if strcmp(method, 'MPC')
                Controller.create('MPC');
            elseif strcmp(method, 'Fix')
                Controller.create('Fix');
            else
                error('Error: method is invalid.');
            end

            % ElementsにControllerをプッシュ
            obj.Elements(Controller.get('id')) = Controller;
        end
    else
        error('Property name is invalid.');
    end
end