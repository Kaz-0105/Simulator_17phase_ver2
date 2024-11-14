function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VissimのCOMオブジェクトを設定
        obj.set('Vissim', Net.QueueCounters); 
    elseif strcmp(property_name, 'Elements')
        % QueueCounterを走査
        for signal_head_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % QueueCounterクラスを作成
            QueueCounter = simulator.network.QueueCounter(obj, signal_head_id);

            % ElementsにQueueCounterをプッシュ
            obj.add(QueueCounter);
        end
    else
        error('Property name is not a valid class');
    end
end