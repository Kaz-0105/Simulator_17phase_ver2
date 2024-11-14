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

    elseif strcmp(property_name, 'Road')
        if isprop(obj, 'Link')
            % Roadクラスを設定
            Road = obj.Link.get('Road');
            obj.set('Road', Road);

        elseif isprop(obj, 'Connector')

        end

    elseif strcmp(property_name, 'link_id')
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
        obj.link_id = DataCollPoint.Lane.Link.get('AttValue', 'No');

        % Linksクラスを取得
        Links = obj.DataCollectionMeasurements.get('Network').get('Links');

        % Linkクラスを取得
        Link = Links.itemByKey(obj.link_id);

        % link_idが10000未満のとき
        if strcmp(Link.get('class'), 'connector')
            % from_link_idを取得
            obj.set('from_link_id', DataCollPoint.Lane.Link.FromLink.get('AttValue', 'No'));
        end
    else
        error('Property name is invalid.');
    end
end