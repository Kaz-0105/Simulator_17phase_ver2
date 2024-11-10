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
        
    
    else
        error('Property name is invalid.');
    end
end