function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutingDecisionsクラスのComオブジェクトを取得  
        VehicleRoutingDecisions = obj.get('VehicleRoutingDecisions').get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutingDecisions.ItemByKey(obj.id);
        
    elseif strcmp(property_name, 'Intersection')
        % Intersectionクラスを取得
        obj.Intersection = obj.Road.get('Intersections').output;

    elseif strcmp(property_name, 'VehicleRoutes')
        % VehicleRoutesクラスを作成
        obj.VehicleRoutes = simulator.network.VehicleRoutes(obj);
        
    else
        error('Property name is invalid.');
    end
end