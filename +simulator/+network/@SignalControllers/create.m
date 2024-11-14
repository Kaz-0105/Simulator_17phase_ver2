function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % Comオブジェクトを設定
        obj.set('Vissim', Net.SignalControllers);

    elseif strcmp(property_name, 'Elements')
        % SignalControllersを走査
        for signal_controller_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % SignalControllerクラスを作成
            SignalController = simulator.network.SignalController(obj, signal_controller_id);

            % SignalControllerクラスを追加
            obj.add(SignalController);
        end
    else
        error('Property name is invalid.');
    end
end