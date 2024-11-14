function run(obj, phase_id, type)
    % 現在のフェーズに対応するSignalGroupsを取得
    SignalGroups = obj.PhaseSignalGroupsMap(phase_id);

    % signal_groupを走査
    for signal_group_id = SignalGroups.getKeys()
        % SignalGroupクラスを取得
        SignalGroup = SignalGroups.itemByKey(signal_group_id);

        % 信号を変更
        if strcmp(type, 'red')
            SignalGroup.get('Vissim').set('AttValue', 'State', 1);
        elseif strcmp(type, 'yellow')
            SignalGroup.get('Vissim').set('AttValue', 'State', 2);
        elseif strcmp(type, 'green')
            SignalGroup.get('Vissim').set('AttValue', 'State', 3);
        else
            error('error: Not defined type.');
        end
    end
end