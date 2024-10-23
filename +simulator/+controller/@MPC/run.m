function run(obj)
    % 自動車の位置をまとめる
    obj.update('pos_vehs');

    % 変数のリストを作成
    obj.update('VariableListMap');

    % MLDの行列の更新
    obj.update('MLD');

    % MILPの行列の更新
    obj.update('MILP');
end