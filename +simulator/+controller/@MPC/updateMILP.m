function updateMILP(obj, property_name)
    if strcmp(property_name, 'Constraints')
        
    elseif strcmp(property_name, 'Objective')
        
    elseif strcmp(property_name, 'Intcon')
        
    else
        error('Property name is invalid.');
    end
end