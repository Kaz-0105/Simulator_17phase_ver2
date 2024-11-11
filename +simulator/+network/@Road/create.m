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
        
    elseif strcmp(property_name, 'links')
        % NetworkクラスのComオブジェクトを取得
        Network = obj.Roads.get('Network');
        Net = Network.get('Vissim');

        % LinksのComオブジェクトを取得
        Links = Net.Links;

        % main_linkを初期化
        main_link = struct();

        % linksを取得
        links = obj.road_struct.links;

        % linksを初期化
        obj.set('links', struct());

        % idを取得
        main_link.id = links.main;

        % Comオブジェクトを取得
        main_link.Vissim = Links.ItemByKey(main_link.id);

        % main_linkの長さを取得
        main_link.length = main_link.Vissim.get('AttValue', 'Length2D');

        % lanesを取得
        main_link.lanes = main_link.Vissim.Lanes.Count();

        % linksにmain_linkをプッシュ
        obj.links.main = main_link;

        % 分岐が存在する場合
        if isfield(links, 'branch')
            % 左に分岐が存在する場合
            if isfield(links.branch, 'left')
                % branch_leftを初期化
                branch_left = struct();

                % linkを初期化
                link = struct();

                % linkのidを取得
                link.id = links.branch.left;

                % Comオブジェクトを取得
                link.Vissim = Links.ItemByKey(link.id);

                % linkの長さを取得
                link.length = link.Vissim.get('AttValue', 'Length2D');

                % linkをbranch_leftにプッシュ
                branch_left.link = link;

                % connectorを探す
                for Link = Links.GetAll()'
                    % セルから取り出し
                    Link = Link{1};

                    % FromLinkを取得
                    FromLink = Link.FromLink;

                    if isempty(FromLink)
                        continue;
                    end

                    if FromLink.get('AttValue', 'No') == main_link.id
                        % connectorを初期化
                        connector = struct();

                        % idを設定
                        connector.id = Link.get('AttValue', 'No');

                        % Comオブジェクトを設定
                        connector.Vissim = Link;

                        % connectorの長さを取得
                        connector.length = Link.get('AttValue', 'Length2D');

                        % from_posとto_posを取得
                        connector.from_pos = Link.get('AttValue', 'FromPos');
                        connector.to_pos = Link.get('AttValue', 'ToPos');

                        % branch_leftにconnectorをプッシュ
                        branch_left.connector = connector;

                        % branch_leftをlinksにプッシュ
                        obj.links.branch.left = branch_left;

                        break;
                    end
                end
            end

            % 右に分岐が存在する
            if isfield(links.branch, 'right')
                % branch_rightを初期化
                branch_right = struct();

                % linkを初期化
                link = struct();

                % linkのidを取得
                link.id = links.branch.right;

                % Comオブジェクトを取得
                link.Vissim = Links.ItemByKey(link.id);

                % linkの長さを取得
                link.length = link.Vissim.get('AttValue', 'Length2D');

                % linkをbranch_rightにプッシュ
                branch_right.link = link;

                % connectorを探す
                for Link = Links.GetAll()'
                    % セルから取り出し
                    Link = Link{1};

                    % FromLinkを取得
                    FromLink = Link.FromLink;

                    if isempty(FromLink)
                        continue;
                    end

                    if FromLink.get('AttValue', 'No') == main_link.id
                        % connectorを初期化
                        connector = struct();

                        % idを設定
                        connector.id = Link.get('AttValue', 'No');

                        % Comオブジェクトを設定
                        connector.Vissim = Link;

                        % connectorの長さを取得
                        connector.length = Link.get('AttValue', 'Length2D');

                        % from_posとto_posを取得
                        connector.from_pos = Link.get('AttValue', 'FromPos');
                        connector.to_pos = Link.get('AttValue', 'ToPos');

                        % branch_rightにconnectorをプッシュ
                        branch_right.connector = connector;

                        % branch_rightをlinksにプッシュ
                        obj.links.branch.right = branch_right;

                        break;
                    end
                end
            end
        end
    elseif strcmp(property_name, 'DataCollections')
        % InputDataCollectionsとOutputDataCollectionsを初期化
        obj.DataCollections.input = simulator.network.DataCollectionMeasurements(obj);
        obj.DataCollections.output = simulator.network.DataCollectionMeasurements(obj);

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