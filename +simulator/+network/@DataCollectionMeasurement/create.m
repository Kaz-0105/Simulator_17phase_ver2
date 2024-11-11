function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % DataCollectionMeasurementsのComオブジェクトを取得
        DataCollMeas = obj.DataCollectionMeasurements.get('Vissim');

        % VissimのComオブジェクトを取得
        obj.Vissim = DataCollMeas.ItemByKey(obj.id);
        
    elseif strcmp(property_name, 'Road')
        % DataCollectionPointsのComオブジェクトを取得
        DataCollPoints = obj.Vissim.DataCollectionPoints;

        % バリデーション
        if DataCollPoints.Count() ~= 1
            % 一対一対応でないことを示すエラー
            error('DataCollectionPoint is not one-to-one correspondence.');
        end

        % DataCollectionPointクラスを取得
        DataCollPoint = DataCollPoints.GetAll();
        DataCollPoint = DataCollPoint{1};

        % link_idを取得
        link_id = DataCollPoint.Lane.Link.get('AttValue', 'No');

        % Networkクラスを取得
        Network = obj.DataCollectionMeasurements.get('Network');

        % LinkRoadMapを取得
        LinkRoadMap = obj.DataCollectionMeasurements.get('LinkRoadMap');

        if link_id < 10000
            % Roadクラスを取得
            Road = Network.Roads.itemByKey(LinkRoadMap(link_id));

            % 流入道路か流出道路かで分岐
            if isprop(Road, 'VehicleRoutingDecision')
                Road.DataCollections.input.add(obj, Road.DataCollections.input.count() + 1);
            else
                Road.DataCollections.output.add(obj, Road.DataCollections.output.count() + 1);
            end

        else
            % from_link_idを取得
            from_link_id = DataCollPoint.Lane.Link.FromLink.get('AttValue', 'No');

            % from_road_idを取得

        end
    else
        error('Property name is invalid.');
    end
end