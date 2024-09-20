function create(obj, property_name)
    if strcmp(property_name, 'Roads')
        % Roadsクラスを作成
        obj.InputRoads = simulator.field.Roads(obj, 'input');
        obj.OutputRoads = simulator.field.Roads(obj, 'output');
    else
        error('error: Property name is invalid.');
    end
end