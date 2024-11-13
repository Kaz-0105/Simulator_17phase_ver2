function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを設定
        obj.Vissim = obj.DelayMeasurements.get('Vissim').ItemByKey(obj.id);
    else
        error('Property name is not valid');
    end
end