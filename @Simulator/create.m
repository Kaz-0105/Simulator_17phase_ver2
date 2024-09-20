function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % Simulatorクラスの設定用の構造体を取得
        simulator = obj.Config.get('simulator');

        % VissimのCOMオブジェクトを取得
        obj.Vissim = actxserver('VISSIM.Vissim');

        % inpxファイルとlayxファイルの読み込み
        inpx_file = [pwd, '\layout\', char(simulator.folder), '\network.inpx'];
        layx_file = [pwd, '\layout\', char(simulator.folder), '\network.layx']; 
        obj.Vissim.LoadNet(inpx_file);
        obj.Vissim.LoadLayout(layx_file);
    else
        error('error: invalid property_name');
    end
end