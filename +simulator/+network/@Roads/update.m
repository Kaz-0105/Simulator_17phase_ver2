function update(obj, property_name)
    if strcmp(property_name, 'Vehicles')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % Roadクラスにいる自動車を更新
            Road.update('Vehicles');
        end
        
    else
        error('error: Property name is invalid.');
    end
end