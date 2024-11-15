function update(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Simulatorクラスを取得
        Simulator = obj.Controllers.get('Simulator');

        % current_timeの更新
        obj.current_time = Simulator.get('current_time');

        % 手法ごとにcurrent_timeの更新
        if isprop(obj, 'Mpc')
            obj.Mpc.set('current_time', obj.current_time);
        elseif isprop(obj, 'Fix')
            obj.Fix.set('current_time', obj.current_time);
        elseif isprop(obj, 'Scoot')
            obj.Scoot.set('current_time', obj.current_time);
        else
            error('Method is invalid.');
        end

    else
        error('property_name is invalid.');
    end
end