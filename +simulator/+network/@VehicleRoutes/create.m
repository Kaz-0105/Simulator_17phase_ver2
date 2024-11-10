function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VehicleRoutingDecisionクラスのComオブジェクトを取得  
        VehicleRoutingDecision = obj.VehicleRoutingDecision.get('Vissim');

        % Comオブジェクトを設定
        obj.Vissim = VehicleRoutingDecision.VehRoutSta;
    elseif strcmp(property_name, 'Elements')
        % Elementsを初期化  
        obj.Elements = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % VehicleRouteを走査
        for vehicle_route_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % VehicleRouteクラスを作成
            VehicleRoute = simulator.network.VehicleRoute(obj, vehicle_route_id);

            % VehicleRouteクラスを追加
            obj.add(VehicleRoute);
        end
    elseif strcmp(property_name, 'order')
        Intersection = obj.VehicleRoutingDecision.get('Intersection');
        RoadOrderMap = Intersection.get('RoadOrderMap');

        num_roads = int32(RoadOrderMap.Count()) / 2;

        FromRoad = obj.VehicleRoutingDecision.get('Road');
        from_road_order = RoadOrderMap(FromRoad.get('id'));

        for vehicle_route_id = obj.getKeys()
            VehicleRoute = obj.itemByKey(vehicle_route_id);

            ToRoad = VehicleRoute.get('Road');
            to_road_order = RoadOrderMap(ToRoad.get('id'));

            order = 0;
            while true
                order = order + 1;

                if mod((from_road_order + order) - to_road_order, num_roads) == 0
                    break;
                end
            end

            VehicleRoute.set('order', order);
        end
    elseif strcmp(property_name, 'rel_flow')
        % Networkクラス用の設定を取得
        network_config = obj.Config.get('network');

        % IntersectionクラスとRoadクラスを取得
        Intersection = obj.VehicleRoutingDecision.get('Intersection');
        Road = obj.VehicleRoutingDecision.get('Road');

        % IntersectionとRoadのIDを取得
        intersection_id = Intersection.get('id');
        road_id = Road.get('id');

        % road_orderを取得
        RoadOrderMap = Intersection.get('RoadOrderMap');
        road_order = RoadOrderMap(road_id);

        % rel_flowsを取得
        rel_flows = network_config.intersections.IntersectionsMap(intersection_id).input_roads(road_order).rel_flows;

        % route_countsを初期化
        route_order_counts = zeros(1, length(rel_flows));

        % VehicleRouteを走査
        for vehicle_route_id = obj.getKeys()
            % VehicleRouteクラスを取得
            VehicleRoute = obj.itemByKey(vehicle_route_id);
            
            % orderを取得
            order = VehicleRoute.get('order');

            % route_order_countsを更新
            route_order_counts(order) = route_order_counts(order) + 1;
        end

        % VehicleRouteを走査
        for vehicle_route_id = obj.getKeys()
            % VehicleRouteクラスを取得
            VehicleRoute = obj.itemByKey(vehicle_route_id);
            
            % orderを取得
            order = VehicleRoute.get('order');

            % rel_flowを取得
            rel_flow = rel_flows(order);

            % rel_flowを設定
            VehicleRoute.set('rel_flow', rel_flow.value / route_order_counts(order));

            % Vissimに反映
            VehicleRoute.get('Vissim').set('AttValue', 'RelFlow(1)', VehicleRoute.get('rel_flow'));
        end
    else
        error('Property name is invalid.');
    end
end