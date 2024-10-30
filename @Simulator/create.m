function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを作成
        Vissim = obj.Config.get('Vissim');

        % SimulatorのCOMオブジェクトを設定
        obj.Vissim = Vissim.Simulation;

        % Simulatorクラス用の設定を取得
        simulator = obj.Config.get('simulator');

        % シード値を設定
        obj.seed = simulator.seed;

        % Vissimにシード値を設定
        obj.Vissim.set('AttValue', 'RandSeed', obj.seed);
        
    elseif strcmp(property_name, 'dt')
        % Simulatorクラス用の設定を取得
        simulator = obj.Config.get('simulator');

        % ステップ時間を設定
        obj.dt = simulator.dt;
    elseif strcmp(property_name, 'time')
        % Simulatorクラス用の設定を取得
        simulator = obj.Config.get('simulator');

        % シミュレーション時間を設定
        obj.time = simulator.time;

        % Vissimにシミュレーション時間を設定
        obj.Vissim.set('AttValue', 'SimPeriod', simulator.time);
    else
        error('error: invalid property_name');
    end
end