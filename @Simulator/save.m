function save(obj)
    % Simulatorクラス用の設定を取得する
    simulator = obj.Config.get('simulator');

    % フォルダが存在しない場合は作成する
    if ~exist([pwd, '/results/', simulator.folder], 'dir')
        mkdir([pwd, '/results/', simulator.folder]);
    end
end