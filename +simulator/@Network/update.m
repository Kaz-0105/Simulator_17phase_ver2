function update(obj, property_name)
    if strcmp(property_name, 'Intersections')
        % Intersectionクラスに接続しているRoadクラスをセット
        obj.Intersections.create('Roads');

    elseif strcmp(property_name, 'Roads')
        % Roadクラスに接続しているIntersectionクラスをセット
        obj.Roads.create('Intersections');

    elseif strcmp(property_name, 'Vehicles')
        % Roadクラスにいる自動車を更新
        obj.Roads.update('Vehicles');
    else
        error('error: Property name is invalid.');
    end
end