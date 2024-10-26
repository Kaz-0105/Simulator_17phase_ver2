function create(obj, property_name)
    if strcmp(property_name, 'Roads')
        % Roadsクラスを作成
        obj.InputRoads = simulator.network.Roads(obj, 'input');
        obj.OutputRoads = simulator.network.Roads(obj, 'output');
    elseif strcmp(property_name, 'order_id')
        % SignalGroupsMapを取得
        SignalGroupsMap = obj.signal_controller.signal_groups.SignalGroupsMap;

        % SignalGroupsMapを走査
        for signal_group_id = cell2mat(SignalGroupsMap.keys())
            % signal_groupを取得
            signal_group = SignalGroupsMap(signal_group_id);

            % SignalHeadsMapを取得
            SignalHeadsMap = signal_group.signal_heads.SignalHeadsMap;

            % SignalHeadsMapを走査
            for signal_head_id = cell2mat(SignalHeadsMap.keys())
                % signal_headを取得
                signal_head = SignalHeadsMap(signal_head_id);

                % VissimのComオブジェクトを取得
                SignalHead = signal_head.Vissim;

                % FromLinkとToLinkを取得
                FromLink = SignalHead.Lane.Link.FromLink;
                ToLink = SignalHead.Lane.Link.ToLink;

                % from_link_idとto_link_idを取得
                from_link_id = FromLink.get('AttValue', 'No');
                to_link_id = ToLink.get('AttValue', 'No');

                % found_flagの初期化
                found_flag = false;

                % InputRoadを走査
                for road_id = obj.InputRoads.getKeys()
                    % Roadクラスを取得
                    Road = obj.InputRoads.itemByKey(road_id);

                    % target_link_idsを初期化
                    target_link_ids = [];

                    % メインリンクのIDをtarget_link_idsに追加
                    target_link_ids(1, end + 1) = Road.links.main.id;
                    
                    % 分岐がある場合
                    if isfield(Road.links, 'branch')
                        if isfield(Road.links.branch, 'left')
                            % ブランチリンクのIDをtarget_link_idsに追加
                            target_link_ids(1, end + 1) = Road.links.branch.left.link.id;
                        end

                        if isfield(Road.links.branch, 'right')
                            % ブランチリンクのIDをtarget_link_idsに追加
                            target_link_ids(1, end + 1) = Road.links.branch.right.link.id;
                        end
                    end

                    % from_linkとmain_linkのIDが一致した場合
                    if ismember(from_link_id, target_link_ids)
                        % 初めての場合かどうかで場合分け
                        if ~isfield(signal_group, 'from_road_id')
                            % signal_groupにfrom_road_idをプッシュ
                            signal_group.from_road_id = road_id;
                        else
                            % 一致しない場合はエラー
                            if signal_group.from_road_id ~= road_id
                                error('error: from_road_id is invalid.');
                            end
                        end

                        % found_flagを更新
                        found_flag = true;
                    end

                    if found_flag
                        break;
                    end
                end

                % found_flagの初期化
                found_flag = false;

                % OutputRoadを走査
                for road_id = obj.OutputRoads.getKeys()
                    % Roadクラスを取得
                    Road = obj.OutputRoads.itemByKey(road_id);

                    % main_link_idを取得
                    main_link_id = Road.links.main.id;

                    % to_linkとmain_linkのIDが一致した場合
                    if main_link_id == to_link_id
                        % 初めての場合かどうかで場合分け
                        if ~isfield(signal_group, 'to_road_id')
                            % signal_groupにto_road_idをプッシュ
                            signal_group.to_road_id = road_id;
                        else
                            % 一致しない場合はエラー
                            if signal_group.to_road_id ~= road_id
                                error('error: to_road_id is invalid.');
                            end
                        end

                        % found_flagを更新
                        found_flag = true;
                    end

                    if found_flag
                        break;
                    end
                end
            end

            % 次の処理で必要なカウンターを初期化
            count = 0;

            while true
                % countをインクリメント
                count = count + 1;

                % 条件を満たすとき
                if mod(signal_group.from_road_id + count - signal_group.to_road_id, obj.InputRoads.count()) == 0
                    % order_idを設定
                    order_id = (signal_group.from_road_id -1) * (obj.InputRoads.count() - 1) + count;

                    % order_idをsignal_groupにプッシュ
                    signal_group.order_id = order_id;
                    break;
                end
            end

            % signal_groupをSignalGroupsMapにプッシュ
            SignalGroupsMap(signal_group_id) = signal_group;
        end

        % SignalGroupsMapをsignal_controllerにプッシュ
        obj.signal_controller.signal_groups.SignalGroupsMap = SignalGroupsMap;
    else
        error('error: Property name is invalid.');
    end
end