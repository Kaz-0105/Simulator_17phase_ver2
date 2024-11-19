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
    elseif strcmp(property_name, 'delay_table')
        % record_flagsを取得
        record_flags = obj.Road.get('record_flags');

        % record_flags.delay_timeがtrueの場合
        if record_flags.delay_time
            % delay_tableを作成
            variable_names = {'time', 'average_delay_time', 'max_delay_time'};
            variable_types = {'double', 'double', 'double'};
            variable_size = [0, 3];
            obj.set('delay_table', table('Size', variable_size,'VariableNames', variable_names, 'VariableTypes', variable_types));
            
            % average_delay_time, max_delay_timeを初期化
            obj.set('average_delay_time', 0);
            obj.set('max_delay_time', 0);
        end

    else
        error('Property name is not valid.');
    end
end