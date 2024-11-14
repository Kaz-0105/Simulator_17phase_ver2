function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % SignalControllerクラスのComオブジェクトを取得
        SignalController = obj.SignalController.get('Vissim');

        % Comオブジェクトを設定
        obj.set('Vissim', SignalController.SGs);

    elseif strcmp(property_name, 'Elements')
        % SignalGroupsを走査
        for signal_group_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % SignalGroupクラスを作成
            SignalGroup = simulator.network.SignalGroup(obj, signal_group_id);

            % SignalGroupクラスを追加
            obj.add(SignalGroup);
        end
    else
        error('Property name is invalid.');
    end
end