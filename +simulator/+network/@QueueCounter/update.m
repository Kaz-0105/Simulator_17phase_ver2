function update(obj, property_name)
    if strcmp(property_name, 'queue_table')
        % queue_lengthを取得
        obj.queue_length = round(obj.Vissim.get('AttValue', 'QLen(Current, Last)'), 1);

        % queue_tableにプッシュ
        obj.queue_table(end + 1, :) = {obj.Timer.get('current_time'), obj.queue_length};
    else
        error('property_name is invalid');
    end
end