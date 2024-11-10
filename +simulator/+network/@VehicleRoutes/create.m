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
        
    else
        error('Property name is invalid.');
    end
end