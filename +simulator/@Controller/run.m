function run(obj)
    if isprop(obj, 'MPC')
        % skip_flagの更新
        obj.MPC.update('skip_flag');
        
        % skip_flagによって分岐
        if obj.MPC.get('skip_flag')
            return;
        else
            obj.MPC.run();
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

    elseif isprop(obj, 'SCOOT')
        % skip_flagの更新
        obj.SCOOT.update('skip_flag');

        % skip_flagによって分岐
        if obj.SCOOT.get('skip_flag')
            return;
        else
            obj.SCOOT.run();
        end
    else
        error('Error: property name is invalid.');
    end
end