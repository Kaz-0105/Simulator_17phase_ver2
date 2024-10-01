function run(obj)
    % シミュレーションを実行
    while (obj.current_time < obj.time)
        % Networkクラスを更新
        obj.Network.update('Vehicles');

        % Controllersクラスを更新
        obj.Controllers.update('Solver');

        % Vissimをステップ時間だけ進める

        % 現在の時間を更新
        obj.current_time = obj.current_time + obj.dt;
    end
end