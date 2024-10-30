function update(obj, property_name)
    if strcmp(property_name, 'break_point')
        % break_pointの更新
        obj.break_point = obj.break_point + obj.dt;

        % break_pointをvissimに反映する
        obj.Vissim.set('AttValue', 'SimBreakAt', obj.break_point);
    elseif strcmp(property_name, 'running_flag')
        % Vissimが動いているとき
        if obj.Vissim.get('AttValue', 'isRunning')
            % running_flagをtrueにする
            obj.running_flag = true;

            % Intersectionsクラスを取得
            Intersections = obj.Network.get('Intersections');

            % 信号の入力の決定権をMatlabに移す
            Intersections.update('SignalGroup');
        end
    else
        error('Error: property name is invalid.');
    end
end