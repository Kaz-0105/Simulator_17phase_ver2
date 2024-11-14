function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VehicleInputsクラスのComオブジェクトを取得    
        VehicleInputs = Net.VehicleInputs;

        % VehicleInputを走査
        for vehicle_input_id = utils.class.Container.getVissimKeys(VehicleInputs)
            % VehicleInputクラスを作成
            VehicleInput = simulator.network.VehicleInput(obj, vehicle_input_id);

            % VehicleInputクラスを追加
            obj.add(VehicleInput);
        end
    else
        error('Property name is invalid.'); 
    end
end