function update(obj, property_name)
    if strcmp(property_name, 'delay_table')
        % 要素クラスを走査
        for measurement_id = obj.getKeys()
            % DelayMeasurementクラスを取得
            DelayMeasurement = obj.itemByKey(measurement_id);

            % DelayMeasurementクラスのupdateメソッドを実行
            DelayMeasurement.update('delay_table');
        end

        % average_delay_time, max_delay_timeを初期化
        obj.average_delay_time = 0;
        obj.max_delay_time = 0;

        % 要素クラスを走査
        for measurement_id = obj.getKeys()
            % DelayMeasurementクラスを取得
            DelayMeasurement = obj.itemByKey(measurement_id);

            % average_delay_time, max_delay_timeを更新
            obj.average_delay_time = obj.average_delay_time + DelayMeasurement.get('delay_time') / obj.count();
            obj.max_delay_time = max(obj.max_delay_time, DelayMeasurement.get('delay_time'));
        end

        % delay_tableを更新
        obj.delay_table(end + 1, :) = {obj.Timer.get('current_time'), obj.average_delay_time, obj.max_delay_time};
    else
        error('Property name is invalid');
    end
end