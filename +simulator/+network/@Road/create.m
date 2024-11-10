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
        
    elseif strcmp(property_name, 'Intersections')
        % Intersectionsクラスを取得
        Intersections = obj.Roads.get('Intersections');

        % Intersectionクラスを走査
        for intersection_id = 1: Intersections.count()
            Intersection = Intersections.itemByKey(intersection_id);

            % InputRoadsクラスを取得
            InputRoads = Intersection.get('InputRoads');

            for input_road_id = InputRoads.getKeys()
                % Roadクラスを取得
                Road = InputRoads.itemByKey(input_road_id);

                if obj.id == Road.get('id')
                    % プロパティにOutputIntersectionクラスを追加
                    prop = addprop(obj, 'OutputIntersection');
                    prop.SetAccess = 'public';
                    prop.GetAccess = 'public';

                    % OutputIntersectionクラスを設定
                    obj.OutputIntersection = Intersection;

                    % Intersectionクラスの設定を取得
                    intersections = obj.Config.get('network').intersections;

                    % IntersectionsMapを取得
                    IntersectionsMap = intersections.IntersectionsMap;

                    % intersection構造体を取得
                    intersection = IntersectionsMap(Intersection.get('id'));

                    % roadsを取得
                    roads = intersection.input_roads;

                    % road構造体を取得
                    road = roads(input_road_id);

                    % routind_decisionにrel_flowsを設定
                    obj.routing_decision.rel_flows = road.rel_flows;
                end
            end

            % OutputRoadsクラスを取得
            OutputRoads = Intersection.get('OutputRoads');

            for output_road_id = OutputRoads.getKeys()
                % Roadクラスを取得
                Road = OutputRoads.itemByKey(output_road_id);

                if obj.id == Road.get('id')
                    % プロパティにInputIntersectionクラスを追加
                    prop = addprop(obj, 'InputIntersection');
                    prop.SetAccess = 'public';
                    prop.GetAccess = 'public';

                    % InputIntersectionクラスを設定
                    obj.InputIntersection = Intersection;
                end
            end
        end
    elseif strcmp(property_name, 'links')
        % NetworkクラスのComオブジェクトを取得
        Network = obj.Roads.get('Network');
        Net = Network.get('Vissim');

        % LinksのComオブジェクトを取得
        Links = Net.Links;

        % main_linkを初期化
        main_link = struct();

        % idを取得
        main_link.id = obj.links.main;

        % Comオブジェクトを取得
        main_link.Vissim = Links.ItemByKey(main_link.id);

        % main_linkの長さを取得
        main_link.length = main_link.Vissim.get('AttValue', 'Length2D');

        % lanesを取得
        main_link.lanes = main_link.Vissim.Lanes.Count();

        % linksにmain_linkをプッシュ
        obj.links.main = main_link;

        % 分岐が存在する場合
        if isfield(obj.links, 'branch')
            % 左に分岐が存在する場合
            if isfield(obj.links.branch, 'left')
                % branch_leftを初期化
                branch_left = struct();

                % linkを初期化
                link = struct();

                % linkのidを取得
                link.id = obj.links.branch.left;

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
            if isfield(obj.links.branch, 'right')
                % branch_rightを初期化
                branch_right = struct();

                % linkを初期化
                link = struct();

                % linkのidを取得
                link.id = obj.links.branch.right;

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
    elseif strcmp(property_name, 'routes')
        % Intersectionクラスを取得
        Intersection = obj.OutputIntersection;

        % Roadsクラスを取得
        InputRoads = Intersection.get('InputRoads');
        OutputRoads = Intersection.get('OutputRoads');

        % num_roadsを取得
        num_roads = OutputRoads.count();

        % Roadクラスを走査
        for road_id = OutputRoads.getKeys()
            % Roadクラスを取得
            Road = InputRoads.itemByKey(road_id);

            if obj.id == Road.get('id')
                % order_idを取得
                order_id = road_id;
                break;
            end
        end

        % routing_decisionを取得
        routing_decision = obj.routing_decision;

        % routing_decisionのComオブジェクトを取得
        RoutingDecision = routing_decision.Vissim;

        % RoutesのComオブジェクトを取得
        Routes = RoutingDecision.VehRoutSta;

        % routesを初期化
        routes = struct();

        % RoutesMapを初期化
        RoutesMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

        % RouteOrderMapを初期化
        RouteOrderMap = containers.Map('KeyType', 'double', 'ValueType', 'double');

        % Routeを走査
        for Route = Routes.GetAll()'
            % セルから取り出し
            Route = Route{1};

            % route構造体を初期化
            route = struct();

            % IDを設定
            route.id = Route.get('AttValue', 'No');

            % Comオブジェクトを設定
            route.Vissim = Route;

            % dest_link_idを取得
            route.dest_link_id = Route.DestLink.ToLink.get('AttValue', 'No');

            % Roadクラスを走査
            for tmp_road_id = OutputRoads.getKeys()
                % Roadクラスを取得
                tmpRoad = OutputRoads.itemByKey(tmp_road_id);

                % main_link_idを取得
                main_link_id = tmpRoad.get('links').main.id;

                if route.dest_link_id == main_link_id
                    % dest_road_idを設定
                    route.dest_road_id = tmpRoad.get('id');

                    % tmp_order_idを設定
                    tmp_order_id = tmp_road_id;
                    break;
                end
            end

            count = 0;

            while true
                count = count + 1;

                if mod((order_id + count) - tmp_order_id, num_roads) == 0
                    route.order_id = count;
                    break;
                end
            end

            % RoutesMapにrouteをプッシュ
            RoutesMap(route.id) = route;

            % RouteOrderMapにorder_idをプッシュ
            RouteOrderMap(route.id) = route.order_id;
        end

        % ここからrel_flowの設定

        for rel_flow = routing_decision.rel_flows
            % rel_flow_idを取得
            rel_flow_id = rel_flow.id;

            % tmp_route_idsを初期化
            tmp_route_ids = [];

            % RoutesMapを走査
            for route_id = 1: RouteOrderMap.Count()
                % order_idを取得
                order_id = RouteOrderMap(route_id);

                if order_id == rel_flow_id
                    tmp_route_ids(1, end + 1) = route_id;
                end
            end

            % tmp_num_routesを取得
            tmp_num_routes = length(tmp_route_ids);

            % tmp_route_idsを走査
            for route_id = tmp_route_ids
                % route構造体を取得
                route = RoutesMap(route_id);

                % rel_flowを設定
                route.rel_flow = rel_flow.value / tmp_num_routes;

                % Vissimに設定
                route.Vissim.set('AttValue', 'RelFlow(1)', route.rel_flow);

                % RoutesMapにプッシュ
                RoutesMap(route_id) = route;
            end
        end

        % routesにRoutesMapをプッシュ
        routes.RoutesMap = RoutesMap;

        % routesにRouteOrderMapをプッシュ
        routes.RouteOrderMap = RouteOrderMap;

        % routesをrouting_decisionにプッシュ
        obj.routing_decision.routes = routes;

        % rel_flowsを削除
        obj.routing_decision = rmfield(obj.routing_decision, 'rel_flows');
        
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