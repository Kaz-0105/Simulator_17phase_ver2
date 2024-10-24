function update(obj, property_name)
    if strcmp(property_name, 'break_point')
        % break_pointの更新
        obj.break_point = obj.break_point + obj.dt;

        % break_pointをvissimに反映する
        obj.Vissim.set('AttValue', 'SimBreakAt', obj.break_point);
    else
        error('Error: property name is invalid.');
    end
end