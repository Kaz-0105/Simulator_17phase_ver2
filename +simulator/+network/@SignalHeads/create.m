function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VissimのCOMオブジェクトを設定
        obj.set('Vissim', Net.SignalHeads);

    elseif strcmp(property_name, 'Elements')
        % SignalHeadを走査
        for signal_head_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % SignalHeadクラスを作成
            SignalHead = simulator.network.SignalHead(obj, signal_head_id);

            % ElementsにSignalHeadをプッシュ
            obj.add(SignalHead);
        end

    elseif strcmp(property_name, 'GroupHeadsMap')
        % GroupHeadsMapを作成
        obj.set('GroupHeadsMap', containers.Map('KeyType', 'double', 'ValueType', 'any'));

        % SignalHeadを走査
        for signal_head_id = obj.getKeys()
            % SignalHeadクラスを取得
            SignalHead = obj.itemByKey(signal_head_id);

            % Comオブジェクトを取得
            SigHead = SignalHead.get('Vissim');

            % signal_group_idを取得
            signal_group_id = SigHead.SG.get('AttValue', 'No');

            % GroupHeadsMapに追加
            if isKey(obj.GroupHeadsMap, signal_group_id)
                obj.GroupHeadsMap(signal_group_id) = [obj.GroupHeadsMap(signal_group_id), signal_head_id];
            else
                obj.GroupHeadsMap(signal_group_id) = signal_head_id;
            end
        end
    else
        error('Property name is not a valid class');
    end
end