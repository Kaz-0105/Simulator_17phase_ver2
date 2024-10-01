function create(obj, property_name)
    if strcmp(property_name, 'Roads')
        % Roadsクラスを作成
        obj.InputRoads = simulator.network.Roads(obj, 'input');
        obj.OutputRoads = simulator.network.Roads(obj, 'output');
    elseif strcmp(property_name, 'signal_controller')
        
    else
        error('error: Property name is invalid.');
    end
end