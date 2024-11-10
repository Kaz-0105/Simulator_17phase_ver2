classdef Model < utils.class.Common
    properties
        Config;
        Simulator;
    end

    properties
        table;
        folder;
        file;
        id;
    end

    methods
        function obj = Model(Simulator, file)
            % ConfigクラスとSimulatorクラスを設定
            obj.Config = Simulator.get('Config');
            obj.Simulator = Simulator;

            % フォルダとファイル名を設定する
            obj.folder = obj.Config.get('simulator').folder;
            obj.file = file;

            % idを初期化
            obj.id = NaN;

            % ファイルが存在するとき
            if exist([pwd, '/results/', obj.folder, '/', obj.file, '.csv'], 'file')
                % tableを読み込む
                obj.table = readtable([pwd, '/results/', obj.folder, '/', obj.file, '.csv']);
            else
                % 新しくtableを作成
                obj.create('table');
            end
        end
    end

    methods
        function value = find(obj, type, varargin)
            % 引数の数で分岐
            if nargin == 3
                % conditionsを初期化
                conditions = varargin{1};

            elseif nargin ~= 2
                error('引数の数が不正です');
            end

            
            % tmp_tableを初期化
            tmp_table = obj.table;

            % conditionsが存在するとき
            if exist('conditions', 'var')
                % conditionを走査
                for condition = conditions.keys
                    % condition_splitを取得
                    condition_split = strsplit(condition{1});

                    % condition_splitが2つの要素を持つとき
                    if length(condition_split) == 2
                        if strcmp(condition_split{2}, '==')
                            % 値が文字列か数値かで場合分け
                            if ischar(conditions(condition{1}))
                                tmp_table = tmp_table(strcmp(tmp_table.(condition_split{1}), conditions(condition{1})), :);
                            else
                                tmp_table = tmp_table(tmp_table.(condition_split{1}) == conditions(condition{1}), :);
                            end
                        elseif strcmp(condition_split{2}, '>')
                            tmp_table = tmp_table(tmp_table.(condition_split{1}) > conditions(condition{1}), :);
                        elseif strcmp(condition_split{2}, '>=')
                            tmp_table = tmp_table(tmp_table.(condition_split{1}) >= conditions(condition{1}), :);
                        elseif strcmp(condition_split{2}, '<')
                            tmp_table = tmp_table(tmp_table.(condition_split{1}) < conditions(condition{1}), :);
                        elseif strcmp(condition_split{2}, '<=')
                            tmp_table = tmp_table(tmp_table.(condition_split{1}) <= conditions(condition{1}), :);
                        elseif strcmp(condition_split{2}, '!=')
                            % 値が文字列か数値かで場合分け
                            if ischar(conditions(condition{1}))
                                tmp_table = tmp_table(~strcmp(tmp_table.(condition_split{1}), conditions(condition{1})), :);
                            else
                                tmp_table = tmp_table(tmp_table.(condition_split{1}) ~= conditions(condition{1}), :);
                            end
                        else
                            error('conditionの後半部分が不正です');
                        end
                    else
                        if ischar(conditions(condition{1}))
                            tmp_table = tmp_table(strcmp(tmp_table.(condition_split{1}), conditions(condition{1})), :);
                        else
                            tmp_table = tmp_table(tmp_table.(condition_split{1}) == conditions(condition{1}), :);
                        end
                    end
                end
            else
                tmp_table = obj.table;
            end

            % tmp_tableが空かどうかで場合分け
            if isempty(tmp_table)
                value = NaN;
            else
                if strcmp(type, 'all')
                    value = tmp_table;
                elseif strcmp(type, 'first')
                    value = tmp_table(1, :);
                elseif strcmp(type, 'last')
                    value = tmp_table(end, :);
                elseif strcmp(type, 'count')
                    value = height(tmp_table);
                else
                    error('typeが不正です');
                end
            end
        end

        function flag = setRecord(obj, ValuesMap)
            % typeを設定
            if isnan(obj.id)
                type = 'create';
            else
                type = 'update';
            end

            % ValuesMapをバリデーション
            if ValuesMap.Count() ~= length(obj.table.Properties.VariableNames)
                % flagとobj.idの設定
                flag = false;
                obj.id = NaN;
                return;
            end
            
            % new_recordを初期化
            if strcmp(type, 'create')
                new_record = {obj.table.id(end) + 1};
            elseif strcmp(type, 'update')
                new_record = {obj.id};
            end

            % ValuesMapを走査
            for column_name = obj.table.Properties.VariableNames
                % idのとき
                if strcmp(column_name{1}, 'id')
                    continue;
                end

                % column_nameを取得
                column_name = column_name{1};

                % ValuesMapにcolumn_nameが存在しないとき
                if ~ValuesMap.isKey(column_name)
                    % flagとobj.idの設定
                    flag = false;
                    obj.id = NaN;
                    return;
                end

                % new_recordに値を追加
                if isnumeric(ValuesMap(column_name))
                    new_record{end + 1} = ValuesMap(column_name);
                else
                    new_record{end + 1} = char(ValuesMap(column_name));
                end
            end

            % new_recordをtableにプッシュ
            if strcmp(type, 'create')
                obj.table{end + 1, :} = new_record;
            elseif strcmp(type, 'update')
                obj.table{obj.id == obj.table.id, :} = new_record;
            end

            % flagとobj.idの設定
            flag = true;
            obj.id = NaN;
        end

        function flag = setField(obj, field_name, value)
            % field_nameが存在しないとき
            if ~ismember(field_name, obj.table.Properties.VariableNames)
                % flagとobj.idの設定
                flag = false;
                obj.id = NaN;
                return;
            end

            % valueが数値か文字列かで場合分け
            if isnumeric(value)
                obj.table{obj.id, field_name} = value;
            else
                obj.table{obj.id, field_name} = char(value);
            end

            % flagとobj.idの設定
            flag = true;
            obj.id = NaN;
        end

        function flag = delete(obj)
            % idがNaNのとき
            if isnan(obj.id)
                % flagの設定
                flag = false;
                return;
            end

            % obj.tableからidを削除
            obj.table(obj.id == obj.table.id, :) = [];

            % flagとobj.idの設定
            flag = true;
            obj.id = NaN;
        end
    end

    methods
        create(obj, property_name);
    end
end