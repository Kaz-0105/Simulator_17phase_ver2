function create(obj, property_name, type)
    if strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % 全体のRoadsクラスかIntersectionクラス内のRoadsクラスかを判定
        if type == 1
            % Roadsクラス用の設定を取得
            roads = obj.Config.get('roads');

            for road = roads
                % Roadクラスを作成
                Road = simulator.field.Road(obj);
                Road.set('id', road.id);

                % Elementsにroadをプッシュ
                obj.Elements(road.id) = Road;
            end
        elseif type == 2
            

        else
            error('Type is invalid.');
        end 
    else
        error('Property name is invalid.');
    end
end