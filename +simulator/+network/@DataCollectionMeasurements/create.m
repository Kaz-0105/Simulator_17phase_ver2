function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % DataCollectionMeasurementsクラスのComオブジェクトを設定
        obj.set('Vissim', Net.DataCollectionMeasurements);

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