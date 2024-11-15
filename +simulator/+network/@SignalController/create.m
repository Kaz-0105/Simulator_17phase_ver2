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

    elseif strcmp(property_name, 'OrderGroupMap')
        % GroupOrderMapを初期化
        obj.set('OrderGroupMap', containers.Map('KeyType', 'int32', 'ValueType', 'int32'));

        % SignalGroupを取得
        for signal_group_id = obj.SignalGroups.getKeys()
            % SignalGroupを取得
            SignalGroup = obj.SignalGroups.itemByKey(signal_group_id);
            
            % orderを取得
            order = SignalGroup.get('order');

            % GroupOrderMapにorderをプッシュ
            obj.OrderGroupMap(order) = signal_group_id;
        end
    
    elseif strcmp(property_name, 'PhaseSignalGroupsMap')
        % PhaseSignalGroupsMapを初期化
        obj.PhaseSignalGroupsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % Roadsクラスを取得
        Roads = obj.Intersection.get('Roads').input;

        % Scootの場合
        if strcmp(obj.Intersection.get('method'), 'Scoot')
            if Roads.count() == 4
                % PhaseSignalGroupsMapを設定
                obj.PhaseSignalGroupsMap(1) = [1, 2, 7, 8];
                obj.PhaseSignalGroupsMap(2) = [3, 4, 9, 10];
                obj.PhaseSignalGroupsMap(3) = [4, 5, 10, 11];
                obj.PhaseSignalGroupsMap(4) = [1, 6, 7, 12];

            elseif Roads.count() == 3
                % PhaseSignalGroupsMapを設定
                obj.PhaseSignalGroupsMap(1) = [1, 2, 5];
                obj.PhaseSignalGroupsMap(2) = [1, 3, 4];
                obj.PhaseSignalGroupsMap(3) = [3, 5, 6];

            else
                error('error: Not defined number of roads.');
            end

            for phase_id = 1: obj.PhaseSignalGroupsMap.Count()
                % signal_group_listを取得
                signal_group_list = obj.PhaseSignalGroupsMap(phase_id);

                for i = 1 : length(signal_group_list)
                    order = signal_group_list(i);
                    signal_group_list(i) = obj.OrderGroupMap(order);
                end

                % PhaseSignalGroupsMapに設定
                obj.PhaseSignalGroupsMap(phase_id) = signal_group_list;
            end

        elseif strcmp(obj.Intersection.get('method'), 'Mpc')
        end

        obj.delete('OrderGroupMap');
       
    else
        error('Property name is invalid.');
    end
end