function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを作成
        Vissim = obj.Config.get('Vissim');

        % SimulatorのCOMオブジェクトを設定
        obj.Vissim = Vissim.Simulation;

        % Simulatorクラス用の設定を取得
        simulator_config = obj.Config.get('simulator');

        % シード値を設定
        obj.seed = simulator_config.seed;

        % Vissimにシード値を設定
        obj.Vissim.set('AttValue', 'RandSeed', obj.seed);

    elseif strcmp(property_name, 'ModelsMap')
        % Modelsクラスを初期化
        obj.ModelsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

        % Simulatorクラス用の設定を取得
        simulator_config = obj.Config.get('simulator');
        
        % resultsフォルダが存在しない場合
        if ~exist([pwd, '/results'], 'dir')
            % resultsフォルダを作成
            mkdir([pwd, '/results']);
        end

        % resultsフォルダ内にシミュレーションした環境に対応するフォルダがないとき
        if ~exist([pwd, '/results/', simulator_config.folder], 'dir')
            % シミュレーションした環境に対応するフォルダを作成
            mkdir([pwd, '/results/', simulator_config.folder]);
        end

        % 各種モデルを作成
        obj.ModelsMap('Simulator') = simulator.Model(obj, 'simulator');
        obj.ModelsMap('Intersection') = simulator.Model(obj, 'intersection');
        obj.ModelsMap('Road') = simulator.Model(obj, 'road');
        obj.ModelsMap('Inputs') = simulator.Model(obj, 'inputs');
        obj.ModelsMap('Method') = simulator.Model(obj, 'method');
    else
        error('error: invalid property_name');
    end
end