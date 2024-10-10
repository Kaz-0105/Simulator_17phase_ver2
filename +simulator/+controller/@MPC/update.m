function update(obj, property_name)
    if strcmp(property_name, 'model')
        % MLDの行列の更新
        obj.update('MLD');

        % MILPの行列の更新
        obj.update('MILP');

    elseif strcmp(property_name, 'MLD')
        % MLDsMapの初期化
        obj.MLDsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

        % A行列の更新
        obj.updateMLD('A');

        % B1行列の更新
        obj.updateMLD('B1');

        % B2行列の更新
        obj.updateMLD('B2');

        % B3行列の更新
        obj.updateMLD('B3');

        % C行列の更新
        obj.updateMLD('C');

        % D1行列の更新
        obj.updateMLD('D1');

        % D2行列の更新
        obj.updateMLD('D2');

        % D3行列の更新
        obj.updateMLD('D3');

        % E行列の更新
        obj.updateMLD('E');

        % validateを実行
        obj.validate('MLD');

    elseif strcmp(property_name, 'MILP')
        % MILPsMapの初期化
        obj.MILPsMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

        % 不等式制約（P, q）、等式制約（Peq, qeq）の更新
        obj.updateMILP('Constraints');

        % 目的関数（f）の更新
        obj.updateMILP('Objective');

        % 整数制約（intcon）の更新
        obj.updateMILP('Intcon');

        % 変域（lb, ub）の更新
        obj.updateMILP('Bounds');
    else
        error('Error: property name is invalid.');  
    end
end