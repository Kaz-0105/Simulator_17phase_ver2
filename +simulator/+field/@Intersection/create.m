function create(obj, property_name)
    if strcmp(property_name, 'Roads')
        % Roadsクラスを作成
        obj.Roads = simulator.field.Roads(obj, 2);
    else
        error('error: Property name is invalid.');
    end
end