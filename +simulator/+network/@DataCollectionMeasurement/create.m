function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % DataCollectionMeasurementsのComオブジェクトを取得
        DataCollMeas = obj.DataCollectionMeasurements.get('Vissim');

        % VissimのComオブジェクトを取得
        obj.Vissim = DataCollMeas.ItemByKey(obj.id);

    elseif strcmp(property_name, 'Links')
        % DataCollPointsのComオブジェクトを取得
        DataCollPoints = obj.Vissim.DataCollectionPoints;

        % バリデーション
        if DataCollPoints.Count() ~= 1
            % 一対一対応でないことを示すエラー
            error('DataCollectionPoint is not one-to-one correspondence with DataCollectionMeasurement.');
        end

        % DataCollectionPointのComオブジェクトを取得
        DataCollPoint = DataCollPoints.GetAll();
        DataCollPoint = DataCollPoint{1};

        % link_idを取得
        link_id = DataCollPoint.Lane.Link.get('AttValue', 'No');
        Links = obj.DataCollectionMeasurements.get('Network').get('Links');
        Link = Links.itemByKey(link_id);

        % Linkがコネクタかどうかで分岐
        if strcmp(Link.get('class'), 'connector')
            obj.set('Connector', Link);
            obj.set('FromLink', Link.FromLink);
            obj.set('ToLink', Link.ToLink);
        elseif strcmp(Link.get('class'), 'link')
            obj.set('Link', Link);
        end

    elseif strcmp(property_name, 'Roads')
        % LinkクラスかConnectorクラスかで場合分け
        if isprop(obj, 'Link')
            % Roadクラスを設定
            obj.set('Road', obj.Link.get('Road'));

            % data_collection構造体を初期化
            data_collection.id = obj.id;

            % DataCollectionsクラスを取得
            DataCollections = obj.Road.get('DataCollections');

            % ネットワーク外への流出口か流入口かで場合分け
            if isprop(obj.Road, 'VehicleInput')
                % DataCollectionsにプッシュ
                DataCollections.input.add(obj);

                % typeを設定
                obj.type = 'input';
                data_collection.type = 'input';

                % data_collectionsを更新
                data_collections = obj.Road.get('data_collections');
                data_collections.input = [data_collections.input, data_collection];
                obj.Road.set('data_collections', data_collections);
            else
                % DataCollectionsにプッシュ
                DataCollections.output.add(obj);

                % typeを設定
                obj.type = 'output';
                data_collection.type = 'output';

                % data_collectionsを更新
                data_collections = obj.Road.get('data_collections');
                data_collections.output = [data_collections.output, data_collection];
                obj.Road.set('data_collections', data_collections);
            end

            % DataCollectionsをRoadクラスにプッシュ
            obj.Road.set('DataCollections', DataCollections);
            

        elseif isprop(obj, 'Connector')
            % Roadクラスを設定
            obj.set('FromRoad', obj.FromLink.get('Road'));
            obj.set('ToRoad', obj.ToLink.get('Road'));

            % DataCollectionsクラスを取得
            DataCollections = obj.FromRoad.get('DataCollections');

            % data_collection構造体を初期化
            data_collection.id = obj.id;

            % DataCollectionsにプッシュ
            DataCollections.output.add(obj);
            
            % typeを設定
            obj.type = 'intersection';
            data_collection.type = 'intersection';

            % data_collectionsを更新
            data_collections = obj.FromRoad.get('data_collections');
            data_collections.output = [data_collections.output, data_collection];
            obj.FromRoad.set('data_collections', data_collections);

            % DataCollectionsをRoadクラスにプッシュ
            obj.FromRoad.set('DataCollections', DataCollections);
        end
    else
        error('Property name is invalid.');
    end
end