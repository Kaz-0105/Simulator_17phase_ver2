function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Intersectionクラスを走査
        for intersection_id = obj.getKeys()
            % Intersectionクラスを取得
            Intersection = obj.itemByKey(intersection_id);

            % Intersectionクラスにいる自動車を更新
            Intersection.update('current_time');
        end
        
    elseif strcmp(property_name, 'SignalGroup')
        % Intersectionクラスを走査
        for intersection_id = obj.getKeys()
            % Intersectionクラスを取得
            Intersection = obj.itemByKey(intersection_id);

            % 信号の入力の決定権をMatlabに移す
            Intersection.update('SignalGroup');
        end
    elseif strcmp(property_name, 'Evaluation')
        % Intersectionクラスを走査
        for intersection_id = obj.getKeys()
            % Intersectionクラスを取得
            Intersection = obj.itemByKey(intersection_id);

            % Intersectionクラスの評価指標の測定
            Intersection.update('Evaluation');
        end
        
    else
        error('Property name is invalid.');
    end
end