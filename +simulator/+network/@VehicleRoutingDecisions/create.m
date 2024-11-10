function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = Net.VehicleRoutingDecisionsStatic;

    elseif strcmp(property_name, 'Elements')
        % Elementsを初期化
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % VehicleRoutingDecisionsを走査
        for vehicle_routing_decision_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % VehicleRoutingDecisionクラスを作成
            VehicleRoutingDecision = simulator.network.VehicleRoutingDecision(obj, vehicle_routing_decision_id);

            % VehicleRoutingDecisionクラスを追加
            obj.add(VehicleRoutingDecision);
        end
    
    elseif strcmp(property_name, 'Road')
        % LinkRoadMapの初期化
        LinkRoadMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % Roadsクラスを取得
        Roads = obj.Network.get('Roads');

        % Roadクラスを走査
        for road_id = Roads.getKeys()
            % Roadクラスを取得
            Road = Roads.itemByKey(road_id);

            % links構造体を取得
            links = Road.get('links');

            % LinkRoadMapに追加
            LinkRoadMap(road_id) = links.main.id;
        end

        % RoutingDecisionを走査
        for routing_decision_id = obj.getKeys()
            % RoutingDecisionクラスを取得
            RoutingDecision = obj.itemByKey(routing_decision_id);

            % link_idを取得
            link_id = RoutingDecision.get('Vissim').Link.get('AttValue', 'No');

            % Roadクラスを取得
            Road = Roads.itemByKey(LinkRoadMap(link_id));

            % Roadクラスを設定
            RoutingDecision.set('Road', Road);
            Road.set('VehicleRoutingDecision', RoutingDecision);
        end

    elseif strcmp(property_name, 'Intersection')
        % RoutingDecisionを走査
        for routing_decision_id = obj.getKeys()
            % RoutingDecisionクラスを取得
            RoutingDecision = obj.itemByKey(routing_decision_id);

            % Intersectionクラスを取得
            RoutingDecision.create('Intersection');
        end
    elseif strcmp(property_name, 'VehicleRoutes')
        % RoutingDecisionを走査
        for routing_decision_id = obj.getKeys()
            % RoutingDecisionクラスを取得
            RoutingDecision = obj.itemByKey(routing_decision_id);

            % VehicleRoutesクラスを作成
            RoutingDecision.create('VehicleRoutes');
        end
    elseif strcmp(property_name, 'LinkRoadMap')
        % 動的プロパティを初期化
        prop = addprop(obj, 'LinkRoadMap');
        prop.SetAccess = 'public';
        prop.GetAccess = 'public';

        obj.LinkRoadMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');

        % Roadsクラスを取得
        Roads = obj.Network.get('Roads');

        % Roadクラスを走査
        for road_id = Roads.getKeys()
            % Roadクラスを取得
            Road = Roads.itemByKey(road_id);

            % links構造体を取得
            links = Road.get('links');

            % LinkRoadMapに追加
            obj.LinkRoadMap(links.main.id) = road_id;
        end
    else
        error('Property name is invalid.');
    end
end