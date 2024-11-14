function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % SignalGroupsクラスのComオブジェクトを取得
        SignalGroups = obj.SignalGroups.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = SignalGroups.ItemByKey(obj.id);

    elseif strcmp(property_name, 'SignalHeads')
        % SignalHeadsクラスを初期化
        obj.SignalHeads = simulator.network.SignalHeads(obj);
        obj.signal_heads = [];

        % SignalHeadsクラスを取得
        SignalHeads = obj.SignalGroups.get('SignalController').get('SignalControllers').get('Network').get('SignalHeads');
        GroupHeadsMap = SignalHeads.get('GroupHeadsMap'); 

        for signal_head_id = GroupHeadsMap(obj.id)
            % SignalHeadクラスを取得
            SignalHead = SignalHeads.itemByKey(signal_head_id);

            signal_head.id = signal_head_id;
            signal_head.order = SignalHead.get('order');

            % SignalHeadクラスをSignalHeadsクラスに追加
            obj.SignalHeads.add(SignalHead);
            obj.signal_heads = [obj.signal_heads, signal_head];

            % SignalHeadクラスにSignalGroupクラスを追加
            SignalHead.set('SignalGroup', obj);
        end
    elseif strcmp(property_name, 'Road')
        % SignalHeadを走査
        for signal_head_id = obj.SignalHeads.getKeys()
            % SignalHeadクラスを取得
            SignalHead = obj.SignalHeads.itemByKey(signal_head_id);

            % FromRoadクラスを取得
            FromRoad = SignalHead.get('FromRoad');

            % 初めての調査かどうかで分岐
            if isempty(obj.Road)
                obj.Road = FromRoad;
            else
                % Roadクラスのバリデーション
                if obj.Road.get('id') ~= FromRoad.get('id')
                    error('Road ID is not same.');
                end
            end
        end
    else
        error('Property name is invalid.');
    end
end