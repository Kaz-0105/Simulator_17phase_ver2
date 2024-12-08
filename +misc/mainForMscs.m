% 実験したい条件の指定
inputs_ids = [1, 2, 3];
rel_flows_ids = [1, 2, 3, 4, 5, 6, 7];

% シミュレーション時間の設定
finish_time = 500;

for inputs_id = inputs_ids
    for rel_flows_id = rel_flows_ids
        % Configクラスを初期化
        config = Config();

        % シミュレーション条件の設定
        config.setInputsForMscs(inputs_id);
        config.setRelFlowsForMscs(rel_flows_id);
        config.setFinishTime(finish_time);

        % Simulatorクラスの初期化
        simulator = Simulator(config);

        % Simulatorクラスを実行
        simulator.run();
    end
end