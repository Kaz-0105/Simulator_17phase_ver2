function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = Net.VehicleRoutingDecisionsStatic;

    elseif strcmp(property_name, 'Elements')
        % VehicleRoutingDecisionsを走査
        for vehicle_routing_decision_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % VehicleRoutingDecisionクラスを作成
            VehicleRoutingDecision = simulator.network.VehicleRoutingDecision(obj, vehicle_routing_decision_id);

            % VehicleRoutingDecisionクラスを追加
            obj.add(VehicleRoutingDecision);
        end

    elseif strcmp(property_name, 'Intersection')
        % RoutingDecisionを走査
        for routing_decision_id = obj.getKeys()
            % RoutingDecisionクラスを取得
            RoutingDecision = obj.itemByKey(routing_decision_id);

            % Intersectionクラスを取得
            RoutingDecision.create('Intersection');
        end
    else
        error('Property name is invalid.');
    end
end