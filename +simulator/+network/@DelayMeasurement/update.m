function update(obj, property_name)
    if strcmp(property_name, 'delay_table')
        % delay_timeを取得
        tmp_delay_time = round(obj.Vissim.get('AttValue', 'VehDelay(Current, Last, All)'), 1);

        % delay_timeがnanでない場合は更新（1台も通過していない場合は前回の値を使用）
        if ~isnan(tmp_delay_time)
            obj.delay_time = tmp_delay_time;
        end

        % delay_tableを更新
        obj.delay_table(end + 1, :) = {obj.Timer.get('current_time'), obj.delay_time};

    else
        error('Property name is invalid');
    end
end