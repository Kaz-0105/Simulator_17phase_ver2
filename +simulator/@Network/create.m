function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % ConfigクラスからVissimのCOMオブジェクトを取得
        Vissim = obj.Config.get('Vissim');

        % NetworkクラスのCOMオブジェクトを設定
        obj.Vissim = Vissim.Net;
    elseif strcmp(property_name, 'record_flags')
        % Simulatorクラス用の設定を取得
        simulator = obj.Config.get('simulator');

        % record_flagsを初期化
        obj.record_flags = struct();

        % 評価指標の測定の有無のフラグを設定
        obj.record_flags.queue_length = simulator.evaluation.queue_length;
        obj.record_flags.delay_time = simulator.evaluation.delay_time;
    else
        error('error: invalid property_name');
    end