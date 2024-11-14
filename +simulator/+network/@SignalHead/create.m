function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを設定
        obj.Vissim = obj.SignalHeads.get('Vissim').ItemByKey(obj.id);
    elseif strcmp(property_name, 'Links')
        % LinkのComオブジェクトを設定
        Link = obj.Vissim.Lane.Link;

        % 各種IDの取得
        link_id = Link.get('AttValue', 'No');
        from_link_id = Link.FromLink.get('AttValue', 'No');
        to_link_id = Link.ToLink.get('AttValue', 'No');

        % Linkクラスの設定
        Links = obj.SignalHeads.get('Network').get('Links');
        obj.Link = Links.itemByKey(link_id);
        obj.FromLink = Links.itemByKey(from_link_id);
        obj.ToLink = Links.itemByKey(to_link_id);
    
    elseif strcmp(property_name, 'Roads')   
        % 各種Roadクラスの設定
        obj.FromRoad = obj.FromLink.get('Road');
        obj.ToRoad = obj.ToLink.get('Road');

        % RoadOrderMapの取得
        Intersection = obj.FromRoad.get('Intersections').output;
        RoadOrderMap = Intersection.get('RoadOrderMap');

        % 交差点の道路の数を取得
        num_roads = int32(RoadOrderMap.Count())/2;

        % 信号頭の順番を設定
        from_road_order = RoadOrderMap(obj.FromRoad.get('id'));
        to_road_order = RoadOrderMap(obj.ToRoad.get('id'));

        % 信号機のIDの設定
        signal_head.id = obj.id;
        
        % 信号機の進路の方向を取得
        direction = 0;
        while true
            direction = direction + 1;
            if mod(from_road_order + direction - to_road_order, num_roads) == 0
                break;
            end
        end

        % 信号機の進路の方向を設定
        obj.direction = direction;
        signal_head.direction = direction;

        % FromRoadに信号機の情報を追加
        signal_heads = obj.FromRoad.get('signal_heads');
        obj.FromRoad.set('signal_heads', [signal_heads, signal_head]);
        obj.FromRoad.get('SignalHeads').add(obj);

    else
        error('Property name is invalid.');
    end
end