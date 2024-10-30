function update(obj, property_name)
    if strcmp(property_name, 'SignalGroup')
        % Intersectionクラスを走査
        for intersection_id = obj.getKeys()
            % Intersectionクラスを取得
            Intersection = obj.itemByKey(intersection_id);

            % 信号の入力の決定権をMatlabに移す
            Intersection.update('SignalGroup');
        end
    else
        error('Property name is invalid.');
    end
end