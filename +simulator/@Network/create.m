function create(obj, property_name)
    if strcmp(property_name, 'Vissim')
        % ConfigクラスからVissimのCOMオブジェクトを取得
        Vissim = obj.Config.get('Vissim');

        % NetworkクラスのCOMオブジェクトを設定
        obj.Vissim = Vissim.Net;
    else
        error('error: invalid property_name');
    end