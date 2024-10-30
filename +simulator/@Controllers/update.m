function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Controllerクラスを走査
        for controller_id = obj.getKeys()
            % Controllerクラスを取得
            Controller = obj.itemByKey(controller_id);

            % current_timeの更新
            Controller.update('current_time');
        end
    else
        error('property_name is invalid.');
    end
end