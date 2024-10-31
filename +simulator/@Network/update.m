function update(obj, property_name)
    if strcmp(property_name, 'Vehicles')
        % Roadクラスにいる自動車を更新
        obj.Roads.update('Vehicles');
    elseif strcmp(property_name, 'Evaluation')
        % Roadクラスの評価指標の測定
        obj.Roads.update('Evaluation');

        % Intersectionクラスの評価指標の測定
        obj.Intersections.update('Evaluation');
    elseif strcmp(property_name, 'current_time')
        % current_timeの更新
        obj.current_time = obj.Simulator.get('current_time');

        % RoadクラスとIntersectionクラスの現在の時間を更新
        obj.Roads.update('current_time');
        obj.Intersections.update('current_time');
    else
        error('error: Property name is invalid.');
    end
end