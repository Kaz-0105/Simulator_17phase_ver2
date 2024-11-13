function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのCOMオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VissimのCOMオブジェクトを設定
        obj.set('Vissim', Net.DelayMeasurements);

    elseif strcmp(property_name, 'Elements')

        % DelayMeasurementを走査
        for delay_measurement_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % DelayMeasurementクラスを作成
            DelayMeasurement = simulator.network.DelayMeasurement(obj, delay_measurement_id);

            % ElementsにDelayMeasurementをプッシュ
            obj.add(DelayMeasurement);
        end
    else
        error('Property name is not valid.');
    end
end