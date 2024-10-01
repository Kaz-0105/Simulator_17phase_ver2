function update(obj, property_name)
    if strcmp(property_name, 'Solver')
        for controller_id = obj.count()
            % Controllerクラスを取得
            Controller = obj.itemByKey(controller_id);

            % Controllerのupdateメソッドを起動
            Controller.update('Solver');
        end
    else
        error('Error: property name is invalid.');
    end
end