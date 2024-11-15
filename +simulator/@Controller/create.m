function create(obj, property_name)
    if strcmp(property_name, 'current_time')
        % Simulatorクラスを取得
        Simulator = obj.Controllers.get('Simulator');

        % current_timeを取得
        obj.current_time = Simulator.get('current_time');

    elseif strcmp(property_name, 'Method')
        if isprop(obj, 'Intersection')
            % 制御手法を取得
            method = obj.Intersection.get('method');

            % 制御手法によって分岐
            if strcmp(method, 'Mpc')
                obj.set('Mpc', simulator.controller.Mpc(obj));
            elseif strcmp(method, 'Fix')
                obj.set('Fix', simulator.controller.Fix(obj));
            elseif strcmp(method, 'Scoot')
                obj.set('Scoot', simulator.controller.Scoot(obj));
            else
                error('Error: method is invalid.');
            end
        end
    else
        error('Error: property name is invalid.');
    end
end