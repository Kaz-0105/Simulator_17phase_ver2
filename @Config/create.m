function create(obj, property_name)
    if strcmp(property_name, 'simulator')
        % 構造体を初期化
        obj.simulator = struct();

        % 設定ファイルを読み込む
        data = yaml.loadFile([pwd, '\layout\config.yaml']);

        % シミュレーションに使用するフォルダを設定
        obj.simulator.folder = char(data.simulator.folder);

    elseif strcmp(property_name, 'field')
        % 構造体を初期化
        obj.field = struct();


    elseif strcmp(property_name, 'intersections')
        % 構造体を初期化
        obj.intersections = [];

        % 交差点のデータを取得
        folder = obj.simulator.folder;
        path = [pwd, '\layout\', folder, '\intersections.yaml'];
        data = yaml.loadFile(path);

        % 交差点を走査
        for intersection_data = data.intersections
            % セルから取り出し
            intersection_data = intersection_data{1};

            % 構造体を初期化
            intersection = struct();

            % 交差点のIDを設定
            intersection.id = intersection_data.id;

            % 構造体を初期化
            input_roads = [];

            % 流入道路を操作
            for input_road_data = intersection_data.input_roads
                % セルから取り出し
                input_road_data = input_road_data{1};

                % 構造体を初期化
                input_road = struct();

                % 流入道路の順番のIDを設定
                input_road.id = input_road_data.id;

                % 流入道路の道路IDを設定
                input_road.road_id = input_road_data.road_id;

                % input_roadsにinput_roadをプッシュ
                input_roads = [input_roads, input_road];
            end

            % input_roadsをintersectionにプッシュ
            intersection.input_roads = input_roads;

            % 構造体を初期化
            output_roads = [];

            % 流出道路を走査
            for output_road_data = intersection_data.output_roads
                % セルから取り出し
                output_road_data = output_road_data{1};

                % 構造体を初期化
                output_road = struct();

                % 流出道路の交差点ごとに割り振られたIDを設定
                output_road.id = output_road_data.id;

                % 流出道路の道路IDを設定
                output_road.road_id = output_road_data.road_id;

                % output_roadsにoutput_roadをプッシュ
                output_roads = [output_roads, output_road];
            end

            % output_roadsをintersectionにプッシュ
            intersection.output_roads = output_roads;

            % intersectionsにintersectionをプッシュ
            obj.intersections = [obj.intersections, intersection];
        end

    elseif strcmp(property_name, 'roads')
        obj.roads = [];

        % 道路のデータを取得
        folder = obj.simulator.folder;
        path = [pwd, '\layout\', folder, '\roads.yaml'];
        data = yaml.loadFile(path);

        % 道路を走査
        for road_data = data.roads
            % セルから取り出し
            road_data = road_data{1};

            % 構造体を初期化
            road = struct();

            % 道路のIDを取得
            road.id = road_data.id;

            % 道路のリンクのIDを取得
            road.link_id = road_data.link_id;

            % roadsにroadをプッシュ
            obj.roads = [obj.roads, road];
        end
    else
        error('error: invalid property_name');
    end
end