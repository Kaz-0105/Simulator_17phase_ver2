function update(obj, property_name)
    if strcmp(property_name, 'Solver')
        if isprop(obj, 'MPC')
            % MPCのモデルの更新
            obj.MPC.update('model');

            % MPCの実行
            obj.MPC.run();

        elseif isprop(obj, 'Fix')
            % Fixの実行
            obj.Fix.run();

        else
            error('Error: property name is invalid.');
        end
    else
        error('Error: property name is invalid.');
    end