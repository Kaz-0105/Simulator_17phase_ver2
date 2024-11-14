function create(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Networkクラスを取得
        Network = obj.Roads.get('Network');

        % current_timeを取得
        obj.current_time = Network.get('current_time');

    elseif strcmp(property_name, 'record_flags')
        % Networkクラスを取得
        Network = obj.Roads.get('Network');

        % record_flagsを取得
        obj.record_flags = Network.get('record_flags');
    
    elseif strcmp(property_name, 'Links')
        % Linksクラスを初期化
        obj.Links = simulator.network.Links(obj);

        % linksを取得
        links = obj.road_struct.links;

        % 全体のLinksクラスを取得
        Links = obj.Roads.get('Network').get('Links');

        % MainLinkを取得
        MainLink = Links.itemByKey(links.main);

        % typeを設定
        MainLink.set('type', 'main');

        % メインリンクをLinksにプッシュ
        obj.Links.add(MainLink);
        MainLink.set('Road', obj);  
        
        % 分岐が存在する場合
        if isfield(links, 'branch')
            % Connectorsクラスを初期化
            obj.set('Connectors', simulator.network.Links(obj));

            % 左に分岐が存在する場合
            if isfield(links.branch, 'left')
                % SubLinkを取得
                SubLink = Links.itemByKey(links.branch.left);

                % typeを設定
                SubLink.set('type', 'left');

                % サブリンクをLinksにプッシュ
                obj.Links.add(SubLink);
                Sublink.set('Road', obj);

                % Connectorを走査
                for link_id = Links.getKeys()
                    % Linkクラスを取得
                    Link = Links.itemByKey(link_id);

                    % connectorでない場合スキップ
                    if ~strcmp(Link.get('class'), 'connector')
                        continue;
                    end

                    % ToLinkを取得
                    ToLink = Link.get('ToLink');

                    % サブリンクのIDと一致するかで分岐
                    if ToLink.get('id') == SubLink.get('id')
                        % ConnectorsにLinkをプッシュ
                        obj.Connectors.add(Link);
                        Link.set('Road', obj);
                        
                        % linksに情報を追加
                        links.branch.left(1, end + 1) = Link.get('id');

                        break;
                    end
                end
            end

            if isfield(links.branch, 'right')
                % SubLinkを取得
                SubLink = Links.itemByKey(links.branch.right);

                % typeを設定
                SubLink.set('type', 'right');

                % サブリンクをLinksにプッシュ
                obj.Links.add(SubLink);
                SubLink.set('Road', obj);

                % Connectorを走査
                for link_id = Links.getKeys()
                    % Linkクラスを取得
                    Link = Links.itemByKey(link_id);

                    % connectorでない場合スキップ
                    if ~strcmp(Link.get('class'), 'connector')
                        continue;
                    end

                    % ToLinkを取得
                    ToLink = Link.get('ToLink');

                    % サブリンクのIDと一致するかで分岐
                    if ToLink.get('id') == SubLink.get('id')
                        % ConnectorsにLinkをプッシュ
                        obj.Connectors.add(Link);
                        Link.set('Road', obj);

                        % linksに情報を追加
                        links.branch.right(1, end + 1) = Link.get('id');
                        
                        break;
                    end
                end
            end
        end

        % linksをセット
        obj.links = links;
    elseif strcmp(property_name, 'SignalHeads')
        % SignalHeadsクラスを初期化
        obj.set('SignalHeads', simulator.network.SignalHeads(obj));

        % signal_headsを初期化
        obj.set('signal_heads', []);

    elseif strcmp(property_name, 'QueueCounters')
        % QueueCountersクラスを初期化
        obj.set('QueueCounters', simulator.network.QueueCounters(obj));

        % queue_countersを初期化
        obj.set('queue_counters', []);

    elseif strcmp(property_name, 'DelayMeasurements')
        % DelayMeasurementsクラスを初期化
        obj.set('DelayMeasurements', simulator.network.DelayMeasurements(obj));

        % delay_measurementsを初期化
        obj.set('delay_measurements', []);

    elseif strcmp(property_name, 'DataCollections')
        % DataCollectionsクラスを初期化
        DataCollections.input = simulator.network.DataCollectionMeasurements(obj);
        DataCollections.output = simulator.network.DataCollectionMeasurements(obj);
        obj.set('DataCollections', DataCollections);    

        % data_collectionsを初期化
        data_collections.input = [];
        data_collections.output = [];
        obj.set('data_collections', data_collections);

    elseif strcmp(property_name, 'speed')
        % Networkクラス用の設定を取得
        network = obj.Config.get('network');

        % RoadsMapを取得
        RoadsMap = network.roads.RoadsMap;

        % road構造体を取得
        road = RoadsMap(obj.id);

        % speedを設定
        obj.speed = road.speed;
    else
        error('error: Property name is invalid.');
    end
end