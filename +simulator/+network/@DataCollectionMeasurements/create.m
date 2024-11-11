function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % DataCollectionMeasurementsクラスのComオブジェクトを設定
        obj.set('Vissim', Net.DataCollectionMeasurements);
        
    elseif strcmp(property_name, 'LinkRoadMap')
        % 動的プロパティを初期化
        obj.set('LinkRoadMap', containers.Map('KeyType', 'int32', 'ValueType', 'int32'));
        
        % Roadsクラスを取得
        Roads = obj.Network.get('Roads');

        % Roadクラスを走査
        for road_id = Roads.getKeys()
            % Roadクラスを取得
            Road = Roads.itemByKey(road_id);

            % links構造体を取得
            links = Road.get('links');

            % LinkRoadMapに追加
            obj.LinkRoadMap(links.main.id) = road_id;

            % 分岐が存在する場合
            if isfield(links, 'branch')
                if isfield(links.branch, 'left')
                    branch = links.branch.left;
                end

                if isfield(links.branch, 'right')
                end
            end
        end

    elseif strcmp(property_name, 'Elements') 
        % DataCollectionMeasurementを走査
        for data_coll_meas_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % DataCollectionMeasurementを取得
            DataCollectionMeasurement = simulator.network.DataCollectionMeasurement(obj, data_coll_meas_id);

            % 要素クラスを追加
            obj.add(DataCollectionMeasurement);
        end
    else
        error('Property name is invalid.');
    end
end