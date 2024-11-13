function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % NetworkクラスのComオブジェクトを取得
        Net = obj.Network.get('Vissim');

        % VissimのCOMオブジェクトを設定
        obj.set('Vissim', Net.SignalHeads);

    elseif strcmp(property_name, 'Elements')
        % SignalHeadを走査
        for signal_head_id = utils.class.Container.getVissimKeys(obj.Vissim)
            % SignalHeadクラスを作成
            SignalHead = simulator.network.SignalHead(obj, signal_head_id);

            % ElementsにSignalHeadをプッシュ
            obj.add(SignalHead);
        end

    elseif strcmp(property_name, 'LinkSignalHeadsMap')
    else
        error('Property name is not a valid class');
    end
end