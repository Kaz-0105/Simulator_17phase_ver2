function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutesクラスのComオブジェクトを取得  
        VehicleRoutes = obj.VehicleRoutes.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutes.ItemByKey(obj.id);
        
    else
        error('Property name is invalid.');
    end
end