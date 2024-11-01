function run(obj)
    % シミュレーションを実行
    while (obj.current_time < obj.total_time)
        % Networkクラスを更新
        obj.Network.update('current_time');
        obj.Network.update('Vehicles');

        % 評価指標の測定（eval_intervalごとに実施）
        if mod(obj.current_time, obj.eval_interval) == 0
            obj.Network.update('Evaluation');
        end

        % Controllersクラスを更新
        obj.Controllers.update('current_time');
        obj.Controllers.run();

        % break_pointを更新
        obj.update('break_point');

        % シミュレーションを実行
        obj.Vissim.RunContinuous();

        % 最初の更新のとき
        if ~obj.running_flag 
            obj.update('running_flag');
        end 
        
        % 現在の時間を更新
        obj.current_time = obj.break_point;
    end

    % グラフの描画
    obj.create('graph');

    % 結果の保存
    obj.save();
end