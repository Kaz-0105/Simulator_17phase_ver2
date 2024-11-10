function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutingDecisionsクラスのComオブジェクトを取得  
        VehicleRoutingDecisions = obj.get('VehicleRoutingDecisions').get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutingDecisions.ItemByKey(obj.id);
        
    else
        error('Property name is invalid.');
    end
end