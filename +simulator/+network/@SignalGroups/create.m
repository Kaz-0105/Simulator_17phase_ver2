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
    
    elseif strcmp(property_name, 'orders')
        % SignalGroupを走査
        for signal_group_id = obj.getKeys()
            % SignalGroupクラスを取得
            SignalGroup = obj.itemByKey(signal_group_id);

            % orderを設定
            SignalGroup.create('order');
        end
    else
        error('Property name is invalid.');
    end
end