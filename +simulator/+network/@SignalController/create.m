function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % SignalControllersクラスのComオブジェクトを取得
        SignalControllers = obj.get('SignalControllers').get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = SignalControllers.ItemByKey(obj.id);
    
    elseif strcmp(property_name, 'Intersection')
        % SignalGroupを走査
        for signal_group_id = obj.SignalGroups.getKeys()
            SignalGroup = obj.SignalGroups.itemByKey(signal_group_id);

            % Roadクラスの取得
            Road = SignalGroup.get('Road');

            % 最初の調査かどうかで分岐
            if isempty(obj.Intersection)
                % Intersectionクラスの設定
                obj.Intersection = Road.get('Intersections').output;
                obj.Intersection.set('SignalController', obj);
            else
                % Intersectionクラスのバリデーション
                if obj.Intersection.get('id') ~= Road.get('Intersections').output.get('id')
                    error('Intersection ID is not same.');
                end
            end
        end
    elseif strcmp(property_name, 'signal_groups')
        % signal_groupsを初期化
        obj.signal_groups = [];

        for signal_group_id = obj.SignalGroups.getKeys()
            % SignalGroupクラスを取得
            SignalGroup = obj.SignalGroups.itemByKey(signal_group_id);

            % signal_group構造体に情報を追加
            signal_group.id = signal_group_id;
            signal_group.order = SignalGroup.get('order');
            signal_group.direction = SignalGroup.get('direction');

            % signal_group構造体をsignal_groupsにプッシュ
            obj.signal_groups = [obj.signal_groups, signal_group];  
        end
    else
        error('Property name is invalid.');
    end
end