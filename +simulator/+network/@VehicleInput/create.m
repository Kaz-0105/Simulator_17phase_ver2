function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.VehicleInputs.get('Network').get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = Net.VehicleInputs.ItemByKey(obj.id);
    else
        error('Property name is invalid.');
    end
end