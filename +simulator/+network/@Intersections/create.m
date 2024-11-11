function create(obj, property_name)
    if strcmp(property_name, 'Elements')
        % Intersectionsクラス用の設定を取得
        network = obj.Config.get('network');
        intersections = network.intersections;

        % IntersectionsMapを取得
        IntersectionsMap = intersections.IntersectionsMap;

        for intersection_id = cell2mat(IntersectionsMap.keys())
            % intersection_structを取得
            intersection_struct = IntersectionsMap(intersection_id);

            % Intersectionクラスを作成
            Intersection = simulator.network.Intersection(obj, intersection_struct);

            % Elementsにintersectionをプッシュ
            obj.add(Intersection);
        end

    elseif strcmp(property_name, 'Roads')
        % Intersectionクラスを走査
        for intersection_id = 1: obj.count()
            % Intersectionクラスを取得
            Intersection = obj.itemByKey(intersection_id);

            % IntersectionクラスにRoadsを作成
            Intersection.create('Roads');
        end

    elseif strcmp(property_name, 'signal_controller')
        % SignalControllersMapを初期化
        SignalControllersMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

        % NetworkクラスのCOMオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % SignalControllersのCOMオブジェクトを取得
        SignalControllers = Net.SignalControllers;

        % SignalControllersを走査
        for SignalController = SignalControllers.GetAll()'
            % セルから取り出す
            SignalController = SignalController{1};

            % signal_controller構造体を初期化
            signal_controller = struct();

            % idをsignal_controllerにプッシュ
            signal_controller.id = SignalController.get('AttValue', 'No');

            % COMオブジェクトをsignal_controllerにプッシュ
            signal_controller.Vissim = SignalController;

            % signal_groupsを初期化
            signal_groups = struct();

            % SignalGroupsMapを初期化
            SignalGroupsMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

            % SignalGroupsのCOMオブジェクトを取得
            SignalGroups = SignalController.SGs;

            % SignalGroupsを走査
            for SignalGroup = SignalGroups.GetAll()'
                % セルから取り出す
                SignalGroup = SignalGroup{1};

                % signal_group構造体を初期化
                signal_group = struct();

                % idをsignal_groupにプッシュ
                signal_group.id = SignalGroup.get('AttValue', 'No');

                % COMオブジェクトをsignal_groupにプッシュ
                signal_group.Vissim = SignalGroup;

                % signal_headsを初期化
                signal_heads = struct();

                % SignalHeadsMapを初期化
                SignalHeadsMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

                % SignalHeadsのCOMオブジェクトを取得
                SignalHeads = SignalGroup.SigHeads;

                for SignalHead = SignalHeads.GetAll()'
                    % セルから取り出す
                    SignalHead = SignalHead{1};

                    % signal_head構造体を初期化
                    signal_head = struct();

                    % idをsignal_headにプッシュ
                    signal_head.id = SignalHead.get('AttValue', 'No');

                    % COMオブジェクトをsignal_headにプッシュ
                    signal_head.Vissim = SignalHead;

                    % SignalHeadsMapをsignal_headにプッシュ
                    SignalHeadsMap(signal_head.id) = signal_head;
                end

                % SignalHeadsMapをsignal_headsにプッシュ
                signal_heads.SignalHeadsMap = SignalHeadsMap;

                % signal_headsをsignal_groupにプッシュ
                signal_group.signal_heads = signal_heads;

                % signal_groupをSignalGroupsMapにプッシュ
                SignalGroupsMap(signal_group.id) = signal_group;
            end

            % SignalGroupsMapをsignal_groupsにプッシュ
            signal_groups.SignalGroupsMap = SignalGroupsMap;

            % signal_groupsをsignal_controllerにプッシュ
            signal_controller.signal_groups = signal_groups;

            % SignalControllersMapにsignal_controllerをプッシュ
            SignalControllersMap(signal_controller.id) = signal_controller;
        end

        % Roadsクラスを取得
        Roads = obj.Network.get('Roads');

        % signal_controllerを走査
        for signal_controller_id = cell2mat(SignalControllersMap.keys())
            % signal_controllerを取得
            signal_controller = SignalControllersMap(signal_controller_id);

            % road_idsを初期化
            road_ids = [];

            % SignalGroupsMapを取得
            SignalGroupsMap = signal_controller.signal_groups.SignalGroupsMap;

            % signal_groupを走査
            for signal_group_id = cell2mat(SignalGroupsMap.keys())
                % signal_groupを取得
                signal_group = SignalGroupsMap(signal_group_id);

                % SignalHeadsMapを取得
                SignalHeadsMap = signal_group.signal_heads.SignalHeadsMap;

                % signal_headを走査
                for signal_head_id = cell2mat(SignalHeadsMap.keys())
                    % signal_headを取得
                    signal_head = SignalHeadsMap(signal_head_id);

                    % SignalHeadのComオブジェクトを取得
                    SignalHead = signal_head.Vissim;

                    % ConnectorのComオブジェクトを取得
                    Connector = SignalHead.Lane.Link;

                    % LinkのComオブジェクトを取得
                    Link = Connector.FromLink;

                    % link_idを取得
                    link_id = Link.get('AttValue', 'No');

                    % Roadクラスを走査
                    for road_id = Roads.getKeys()
                        % Roadクラスを取得
                        Road = Roads.itemByKey(road_id);

                        % linksを取得
                        links = Road.get('links');

                        % main_link_idを取得
                        main_link_id = links.main.id;

                        % main_link_idとlink_idが一致した場合
                        if main_link_id == link_id
                            if ~ismember(road_id, road_ids)
                                % road_idsにプッシュ
                                road_ids = [road_ids, road_id];
                            end

                            break;
                        end
                    end
                end
            end

            % Intersectionクラスを走査
            for intersection_id = obj.getKeys()
                % Intersectionクラスを取得
                Intersection = obj.itemByKey(intersection_id);

                % Roadsを取得
                Roads = Intersection.get('Roads');

                % input_road_idsを初期化
                input_road_ids = [];

                % 流入道路を走査
                for order_id = Roads.input.getKeys()
                    % Roadクラスを取得
                    Road = Roads.input.itemByKey(order_id);

                    % road_idを取得
                    road_id = Road.get('id');

                    % input_road_idsにプッシュ
                    input_road_ids = [input_road_ids, road_id];
                end

                % same_flagを初期化
                same_flag = true;

                % road_idsを走査
                for road_id = road_ids
                    % road_idがinput_road_idsに含まれていない場合
                    if ~ismember(road_id, input_road_ids)
                        % different_flagをtrueにする
                        same_flag = false;

                        break;
                    end
                end

                % same_flagがtrueの時
                if same_flag
                    % Intersectionクラスにsignal_controllerをプッシュ
                    Intersection.set('signal_controller', signal_controller);

                    break;
                end
            end
        end

        % Intersectionを走査
        for intersection_id = obj.getKeys()
            % Intersectionクラスを取得
            Intersection = obj.itemByKey(intersection_id);

            % MPCの変数のIDを設定
            Intersection.create('order_id');
        end
        
    else
        error('Property name is invalid.');
    end
end