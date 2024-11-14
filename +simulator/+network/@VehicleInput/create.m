function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.VehicleInputs.get('Network').get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = Net.VehicleInputs.ItemByKey(obj.id);
    elseif strcmp(property_name, 'Link')
        % Linkクラスを取得
        link_id = obj.Vissim.Link.get('AttValue', 'No');
        Links = obj.VehicleInputs.get('Network').get('Links');
        obj.Link = Links.itemByKey(link_id);

    elseif strcmp(property_name, 'Road')
        % Roadクラスを取得
        obj.Road = obj.Link.get('Road');
        obj.Road.set('VehicleInput', obj);

    elseif strcmp(property_name, 'volume')
        % road_structを取得
        road_struct = obj.Road.get('road_struct');

        % volumeを設定
        obj.volume = road_struct.inflows;

        % Vissimに適用
        obj.Vissim.set('AttValue', 'Volume(1)', obj.volume);    

    else
        error('Property name is invalid.');
    end
end