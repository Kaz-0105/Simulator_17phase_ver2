function run(obj)
    % シミュレーションを実行
    while (obj.Timer.get('finish_flag') == false)
        % Networkクラスを更新
        obj.Network.update('Vehicles');

        % 評価指標の更新
        if obj.Timer.get('evaluation_flag')
            obj.Network.update('Evaluation');
        end

        % Controllersクラスを更新
        obj.Controllers.run();

        % Timerクラスを更新
        obj.Timer.run();

        % シミュレーションを実行
        obj.Vissim.set('AttValue', 'SimBreakAt', obj.Timer.get('current_time'));
        obj.Vissim.RunContinuous();

        % 最初の更新のとき
        if ~obj.running_flag 
            obj.update('running_flag');
        end 
    end

    % 性能指標表示
    obj.Network.run();
end