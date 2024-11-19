function run(obj, phase_id, color)
    % group_ordersを取得
    group_orders = obj.PhaseSignalGroupsMap(phase_id);

    % SignalGroupを走査
    for group_order = group_orders
        % SignalGroupクラスを取得
        SignalGroup = obj.SignalGroups.itemByKey(obj.OrderGroupMap(group_order));

        % Comオブジェクトを取得
        SG = SignalGroup.get('Vissim');

        % SignalGroupを設定
        if strcmp(color, 'green')
            SG.set('AttValue', 'State', 3);
        elseif strcmp(color, 'red')
            SG.set('AttValue', 'State', 1); 
        elseif strcmp(color, 'yellow')
            SG.set('AttValue', 'State', 2);
        else
            error('Color is not defined.');
        end
    end
end