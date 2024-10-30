function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % Roadクラスにいる自動車を更新
            Road.update('current_time');
        end
        
    elseif strcmp(property_name, 'Vehicles')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % Roadクラスにいる自動車を更新
            Road.update('Vehicles');
        end
        
    elseif strcmp(property_name, 'Evaluation')
        % Roadクラスを走査
        for road_id = obj.getKeys()
            % Roadクラスを取得
            Road = obj.itemByKey(road_id);

            % Roadクラスの評価指標の測定
            Road.update('Evaluation');
        end
    else
        error('error: Property name is invalid.');
    end
end