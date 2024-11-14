function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutesクラスのComオブジェクトを取得  
        VehicleRoutes = obj.VehicleRoutes.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutes.ItemByKey(obj.id);

    elseif strcmp(property_name, 'Links')
        % LinkのIDを取得
        connector_id = obj.Vissim.DestLink.get('AttValue', 'No');
        from_link_id = obj.Vissim.DestLink.FromLink.get('AttValue', 'No');
        to_link_id = obj.Vissim.DestLink.ToLink.get('AttValue', 'No');

        % Linkクラスを取得
        Links = obj.VehicleRoutes.get('VehicleRoutingDecision').get('VehicleRoutingDecisions').get('Network').get('Links');
        obj.Connector = Links.itemByKey(connector_id);
        obj.FromLink = Links.itemByKey(from_link_id);
        obj.ToLink = Links.itemByKey(to_link_id);

    elseif strcmp(property_name, 'Roads')
        % VehicleRoutingDecisionクラスを取得
        VehicleRoutingDecision = obj.VehicleRoutes.get('VehicleRoutingDecision');

        % Roadクラスを取得
        obj.FromRoad = obj.FromLink.get('Road');
        obj.ToRoad = obj.ToLink.get('Road');
    
    elseif strcmp(property_name, 'vehicle_route')
        % VehicleRoutingDecisionクラスを取得
        VehicleRoutingDecision = obj.VehicleRoutes.get('VehicleRoutingDecision');

        % Intersectionクラスを取得
        Intersection = VehicleRoutingDecision.get('Intersection');
        RoadOrderMap = Intersection.get('RoadOrderMap');

        % 道路の数を取得
        num_roads = int32(RoadOrderMap.Count())/2;

        % vehicle_route構造体を初期化
        vehicle_route.id = obj.id;

        % 道路の順番を取得
        from_road_order = RoadOrderMap(obj.FromRoad.get('id'));
        to_road_order = RoadOrderMap(obj.ToRoad.get('id'));

        % orderを計算
        order = 0;
        while true
            order = order + 1;
            if mod(from_road_order + order - to_road_order, num_roads) == 0
                break;
            end
        end

        % orderを設定
        obj.order = order;
        vehicle_route.order = order;

        % VehicleRoutinDecisionクラスにプッシュ
        vehicle_routes = VehicleRoutingDecision.get('vehicle_routes');
        VehicleRoutingDecision.set('vehicle_routes', [vehicle_routes, vehicle_route]);

    else
        error('Property name is invalid.');
    end
end