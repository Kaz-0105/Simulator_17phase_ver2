function create(obj, property_name)
    if strcmp(property_name, 'table')
        if strcmp(obj.file, 'simulator')
            % namesとtypesを初期化
            names = {'id', 'seed', 'simulation_time'};
            types = {'int32', 'int32', 'int32'};

            % Intersectionsクラスを取得
            Intersections = obj.Simulator.get('Network').get('Intersections');

            % intersection_{id}をnamesに追加
            for id = 1: Intersections.count()
                names{end + 1} = ['intersection_', num2str(id)];
                types{end + 1} = 'int32';
            end

            % 続きを追加
            names = [names, ... 
                { 
                    'inputs_id', 'ave_queue', 'max_queue', 'ave_delay', ...
                    'max_delay', 'ave_calc_time', 'max_calc_time', 'success_rate'
                }   
            ];

            types = [types, ...
                {
                    'int32', 'double', 'double', 'double', ...
                    'double', 'double', 'double', 'double'
                }
            ];

            % tableを作成
            obj.table = table('Size', [0, length(names)], 'VariableNames', names, 'VariableTypes', types);
        elseif strcmp(obj.file, 'intersection')
            % namesとtypesを初期化
            names = {'id', 'num_roads', 'method_id'};
            types = {'int32', 'int32', 'int32'};

            % Intersectionsクラスを取得
            Intersections = obj.Simulator.get('Network').get('Intersections');

            % max_num_roadsを初期化
            max_num_roads = 0;

            % Intersectionクラスを走査
            for intersection_id = Intersections.getKeys()
                % Intersectionクラスを取得
                Intersection = Intersections.itemByKey(intersection_id);

                % 道路の数を取得
                num_roads = Intersection.get('Roads').input.count();

                % max_num_roadsを更新
                if num_roads > max_num_roads
                    max_num_roads = num_roads;
                end
            end

            % road_{id}をnamesに追加
            for id = 1: max_num_roads
                names{end + 1} = ['road_', num2str(id)];
                types{end + 1} = 'int32';
            end

            % tableを作成
            obj.table = table('Size', [0, length(names)], 'VariableNames', names, 'VariableTypes', types);

        elseif strcmp(obj.file, 'road')
            % namesとtypesを初期化
            names = {'id'};
            types = {'int32'};

            % Intersectionsクラスを取得
            Intersections = obj.Simulator.get('Network').get('Intersections');

            % relflow_{id}をnamesに追加
            for id = 1: Intersections.count() - 1
                names{end + 1} = ['relflow_', num2str(id)];
                types{end + 1} = 'double';
            end

            % tableを作成
            obj.table = table('Size', [0, length(names)], 'VariableNames', names, 'VariableTypes', types);

        elseif strcmp(obj.file, 'inputs')
            % namesとtypesを初期化
            names = {'id'};
            types = {'int32'};

        elseif strcmp(obj.file, 'method')
            % namesとtypesを初期化
            names = {'id', 'name'};
            types = {'int32', 'string'};

            % tableを作成
            obj.table = table('Size', [0, length(names)], 'VariableNames', names, 'VariableTypes', types);
        else
            error('File name is invalid.');
        end
    else
        error('Property name is invalid.');
    end
end