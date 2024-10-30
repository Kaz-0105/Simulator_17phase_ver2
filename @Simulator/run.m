function run(obj)
    % シミュレーションを実行
    while (obj.current_time < obj.time)
        % Networkクラスを更新
        obj.Network.update('Vehicles');

        % Controllersクラスを更新
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
end