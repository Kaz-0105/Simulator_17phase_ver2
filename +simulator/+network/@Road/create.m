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

                        % linksに情報を追加
                        links.branch.right(1, end + 1) = Link.get('id');
                        
                        break;
                    end
                end
            end

            % linksをセット
            obj.links = links;
        end
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
        obj.set('data_collections', []);

    elseif strcmp(property_name, 'SignalHead')
        % NetworkクラスのComオブジェクトを取得 
        Network = obj.Roads.get('Network');
        Net = Network.get('Vissim');

        % SignalHeadsのComオブジェクトを取得
        SignalHeads = Net.SignalHeads;

        for SignalHead = SignalHeads.GetAll()'
            % セルから取り出し
            SignalHead = SignalHead{1};

            % SignalHeadが設置されているConnectorを取得
            Connector = SignalHead.Lane.Link;

            % 対応するLinkを取得
            Link = Connector.FromLink;

            % リンクのIDを取得
            link_id = Link.get('AttValue', 'No');

            % SignalHeadがこの道路内に存在するかで分岐
            if link_id == obj.links.main.id
                % link構造体を取得
                link = obj.links.main;

                % signal_head構造体を初期化
                signal_head = struct();

                % id, Comオブジェクト, 位置を取得
                signal_head.id = SignalHead.get('AttValue', 'No');
                signal_head.Vissim = SignalHead;
                signal_head.pos = SignalHead.get('AttValue', 'Pos') + link.length;

                % signal_headsが存在しない場合
                if ~isfield(link, 'signal_heads')
                    link.signal_heads = signal_head;
                else
                    link.signal_heads(1, end + 1) = signal_head;
                end

                % linksにmain_linkをプッシュ
                obj.links.main = link;

            elseif isfield(obj.links, 'branch')
                if isfield(obj.links.branch, 'left')
                    if link_id == obj.links.branch.left.link.id
                        % link構造体を取得
                        link = obj.links.branch.left.link;

                        % signal_head構造体を初期化
                        signal_head = struct();
                        
                        % id, Comオブジェクト, 位置を取得
                        signal_head.id = SignalHead.get('AttValue', 'No');
                        signal_head.Vissim = SignalHead;
                        signal_head.pos = SignalHead.get('AttValue', 'Pos') + link.length;

                        % signal_headsが存在しない場合
                        if ~isfield(link, 'signal_heads')
                            link.signal_heads = signal_head;
                        else
                            link.signal_heads(1, end + 1) = signal_head;
                        end

                        % links.branch.leftにlinkをプッシュ
                        obj.links.branch.left.link = link;
                    end
                elseif isfield(obj.links.branch, 'right')
                    if link_id == obj.links.branch.right.link.id
                        % link構造体を取得
                        link = obj.links.branch.right.link;

                        % signal_head構造体を初期化
                        signal_head = struct();

                        % id, Comオブジェクト, 位置を取得
                        signal_head.id = SignalHead.get('AttValue', 'No');
                        signal_head.Vissim = SignalHead;
                        signal_head.pos = SignalHead.get('AttValue', 'Pos') + link.length;

                        % signal_headsが存在しない場合
                        if ~isfield(link, 'signal_heads')
                            link.signal_heads = signal_head;
                        else
                            link.signal_heads(1, end + 1) = signal_head;
                        end

                        % links.branch.rightにlinkをプッシュ
                        obj.links.branch.right.link = link;
                    end
                end
            end
        end
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