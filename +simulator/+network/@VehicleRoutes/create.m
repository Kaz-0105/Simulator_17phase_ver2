function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutingDecisionクラスのComオブジェクトを取得  
        VehicleRoutingDecision = obj.VehicleRoutingDecision.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutingDecision.VehRoutSta;
    elseif strcmp(property_name, 'Elements')
        % VehicleRouteを走査
        for vehicle_route_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % VehicleRouteクラスを作成
            VehicleRoute = simulator.network.VehicleRoute(obj, vehicle_route_id);

            % VehicleRouteクラスを追加
            obj.add(VehicleRoute);
        end
    elseif strcmp(property_name, 'rel_flows')
        % Intersectionクラスの取得
        Intersection = obj.VehicleRoutingDecision.get('Intersection');
        RoadOrderMap = Intersection.get('RoadOrderMap');

        % intersection_structの取得
        intersection_struct = Intersection.get('intersection_struct');

        % num_roadsの取得
        num_roads = length(intersection_struct.input_roads);

        % road_orderの取得
        road_order = RoadOrderMap(obj.VehicleRoutingDecision.get('Road').get('id'));

        % road_structの取得
        road_struct = intersection_struct.input_roads(road_order);

        % バリデーション
        if road_struct.road_id ~= obj.VehicleRoutingDecision.get('Road').get('id')
            error('Road ID is invalid.');
        end

        % route_counterを初期化        
        route_counter = zeros(1, num_roads - 1);

        % VehicleRouteを走査
        for route_id = obj.getKeys()
            % route_counterを更新
            VehicleRoute = obj.itemByKey(route_id);
            route_counter(VehicleRoute.get('order')) = route_counter(VehicleRoute.get('order')) + 1;
        end

        % rel_flowsを初期化
        rel_flows = zeros(1, num_roads - 1);

        % rel_flowを走査
        for order = 1: length(rel_flows)
            % rel_flowを計算
            rel_flows(order) = road_struct.rel_flows(order).value / route_counter(order);
        end

        % VehicleRouteを走査
        for route_id = obj.getKeys()
            % VehicleRouteクラスを取得
            VehicleRoute = obj.itemByKey(route_id);
            VehicleRoute.set('rel_flow', rel_flows(VehicleRoute.get('order')));
        end
    else
        error('Property name is invalid.');
    end
end