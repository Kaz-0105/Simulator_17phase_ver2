function validate(obj, property_name)
    if strcmp(property_name, 'MLD')
        % MLDHeightMapの初期化
        MLDHeightMap = containers.Map('KeyType', 'char', 'ValueType', 'int32');

        % 行列を走査
        for matrix_name = ["A", "B1", "B2", "B3"]
            % 行列のサイズを取得
            MLDHeightMap(char(matrix_name)) = size(obj.MLDsMap(char(matrix_name)), 1);
        end

        % A, B1, B2, B3の行数が全て等しいか確認
        for matrix_name = ["A", "B1", "B2", "B3"]
            if MLDHeightMap(char(matrix_name)) ~= MLDHeightMap('A')
                error('Error: the number of rows of A, B1, B2, and B3 must be equal.');
            end
        end

    elseif strcmp(property_name, 'MILP')
        
    else
        error('Error: property name is invalid.');
    end
end