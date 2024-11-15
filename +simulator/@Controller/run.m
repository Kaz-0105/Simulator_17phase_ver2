function run(obj)
    if isprop(obj, 'Mpc')
        % skip_flagの更新
        obj.Mpc.update('skip_flag');
        
        % skip_flagによって分岐
        if obj.Mpc.get('skip_flag')
            return;
        else
            obj.Mpc.run();
        end

    elseif isprop(obj, 'Fix')
        % skip_flagの更新
        obj.Fix.update('skip_flag');

        % skip_flagによって分岐
        if obj.Fix.get('skip_flag')
            return;
        else
            obj.Fix.run();
        end

    elseif isprop(obj, 'Scoot')
        % skip_flagの更新
        obj.Scoot.update('skip_flag');

        % skip_flagによって分岐
        if obj.Scoot.get('skip_flag')
            return;
        else
            obj.Scoot.run();
        end
    else
        error('Error: property name is invalid.');
    end
end