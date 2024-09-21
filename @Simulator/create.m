function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを作成
        Vissim = obj.Config.get('Vissim');

        % SimulatorのCOMオブジェクトを設定
        obj.Vissim = Vissim.Simulation;
    else
        error('error: invalid property_name');
    end
end