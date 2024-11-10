function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutingDecisionクラスのComオブジェクトを取得  
        VehicleRoutingDecision = obj.VehicleRoutingDecision.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutingDecision.VehRoutSta;
    elseif strcmp(property_name, 'Elements')
        % Elementsを初期化  
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % VehicleRouteを走査
        for vehicle_route_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % VehicleRouteクラスを作成
            VehicleRoute = simulator.network.VehicleRoute(obj, vehicle_route_id);

            % VehicleRouteクラスを追加
            obj.add(VehicleRoute);
        end
    else
        error('Property name is invalid.');
    end
end