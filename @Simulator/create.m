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
    elseif strcmp(property_name, 'total_time')
        % Simulatorクラス用の設定を取得
        simulator = obj.Config.get('simulator');

        % シミュレーション時間を設定
        obj.total_time = simulator.total_time;

        % Vissimにシミュレーション時間を設定
        obj.Vissim.set('AttValue', 'SimPeriod', simulator.total_time);
    elseif strcmp(property_name, 'eval_interval')
        % Simulatorクラス用の設定を取得
        simulator = obj.Config.get('simulator');

        % 評価指標の測定間隔を設定
        obj.eval_interval = simulator.evaluation.dt;

    elseif strcmp(property_name, 'graph')
        % あとで実装      
    else
        error('error: invalid property_name');
    end
end