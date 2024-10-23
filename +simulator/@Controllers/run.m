function run(obj)
    for controller_id = obj.count()
        % Controllerクラスを取得
        Controller = obj.itemByKey(controller_id);

        % Controllerのupdateメソッドを起動
        Controller.update('Solver');
    end
end