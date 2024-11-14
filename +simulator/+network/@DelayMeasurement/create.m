function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを設定
        obj.Vissim = obj.DelayMeasurements.get('Vissim').ItemByKey(obj.id);

    elseif strcmp(property_name, 'Links')
        % VehicleTravelTimeMeasurementsのCOMオブジェクトを取得
        VehTravTmMeas = obj.Vissim.VehTravTmMeas;

        % バリデーション
        if VehTravTmMeas.Count() ~= 1
            error('Please establish a one-to-one relationship between the DelayMeasurement and VehicleTravelTimeMeasurement.');
        end

        % VehicleTravelTimeMeasurementのCOMオブジェクトを取得
        TravelTimeMeasurement = VehTravTmMeas.GetAll();
        TravelTimeMeasurement = TravelTimeMeasurement{1};

        % LinkのIDを取得
        link_id = TravelTimeMeasurement.EndLink.get('AttValue', 'No');
        from_link_id = TravelTimeMeasurement.StartLink.get('AttValue', 'No');
        to_link_id = TravelTimeMeasurement.EndLink.ToLink.get('AttValue', 'No');
        
        % Linksクラスを取得
        Links = obj.DelayMeasurements.get('Network').get('Links');

        % Linkクラスを設定
        obj.Link = Links.itemByKey(link_id);
        obj.FromLink = Links.itemByKey(from_link_id);
        obj.ToLink = Links.itemByKey(to_link_id);

    elseif strcmp(property_name, 'Roads')
        % Roadクラスを設定
        obj.FromRoad = obj.FromLink.get('Road');
        obj.ToRoad = obj.ToLink.get('Road');

        % Intersectionクラスを取得
        Intersection = obj.FromRoad.get('Intersections').output;
        RoadOrderMap = Intersection.get('RoadOrderMap');

        % 道路数を取得
        num_roads = int32(RoadOrderMap.Count())/2;

        % 道路の順番を取得
        from_road_order = RoadOrderMap(obj.FromRoad.get('id'));
        to_road_order = RoadOrderMap(obj.ToRoad.get('id'));

        % delay_measurement構造体を初期化
        delay_measurement.id = obj.id;

        % 進路の方向を計算
        order = 0;
        while true
            order = order + 1;
            if mod(from_road_order + order - to_road_order, num_roads) == 0
                break;
            end
        end

        % 進路の方向を設定
        delay_measurement.order = order;

        % Roadクラスにプッシュ
        delay_measurements = obj.FromRoad.get('delay_measurements');
        obj.FromRoad.set('delay_measurements', [delay_measurements, delay_measurement]);
        obj.FromRoad.get('DelayMeasurements').add(obj);
        
    else
        error('Property name is not valid');
    end
end