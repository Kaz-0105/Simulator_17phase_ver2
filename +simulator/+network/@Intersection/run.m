function run(obj, phase_id, type)
    % 現在のフェーズに対応するSignalGroupを取得
    SignalGroupsMap = obj.PhaseSignalGroupsMap(phase_id);

    % signal_groupを走査
    for signal_group_id = cell2mat(SignalGroupsMap.keys())
        % signal_group構造体を取得
        signal_group = SignalGroupsMap(signal_group_id);

        % SignalGroupのComオブジェクトを取得
        SignalGroup = signal_group.Vissim;

        % 信号を変更
        if strcmp(type, 'red')
            SignalGroup.set('AttValue', 'State', 1);
        elseif strcmp(type, 'yellow')
            SignalGroup.set('AttValue', 'State', 2);
        elseif strcmp(type, 'green')
            SignalGroup.set('AttValue', 'State', 3);
        else
            error('error: Not defined type.');
        end
    end
end