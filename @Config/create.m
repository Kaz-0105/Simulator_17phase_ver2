function create(obj, property_name)
    if strcmp(property_name, 'simulator')
        % 構造体を初期化
        obj.simulator = struct();

        % 設定ファイルを読み込む
        data = yaml.loadFile([pwd, '\layout\config.yaml']);

        % シミュレーションに使用するフォルダを設定
        obj.simulator.folder = char(data.simulator.folder);

        % ステップ時間を設定
        obj.simulator.dt = data.simulator.dt;

        % シミュレーション時間を設定
        obj.simulator.time = data.simulator.time;

        % Vissimのシード値を設定
        obj.simulator.seed = data.simulator.seed;

        % VissimのシミュレーションのモードをQuickModeにするか設定
        obj.simulator.quick_mode = logical(data.simulator.quick_mode);

    elseif strcmp(property_name, 'Vissim')
        % VissimのCOMオブジェクトを取得
        obj.Vissim = actxserver('VISSIM.Vissim');

        % inpxファイルとlayxファイルの読み込み
        inpx_file = [pwd, '\layout\', char(obj.simulator.folder), '\network.inpx'];
        layx_file = [pwd, '\layout\', char(obj.simulator.folder), '\network.layx']; 
        obj.Vissim.LoadNet(inpx_file);
        obj.Vissim.LoadLayout(layx_file);

        % VissimにQuickModeを設定
        obj.Vissim.Graphics.set('AttValue', 'QuickMode', obj.simulator.quick_mode);

    elseif strcmp(property_name, 'network')
        % 構造体を初期化
        obj.network = struct();

        % Intersectionsクラス用の設定を作成
        obj.create('intersections');

        % Roadsクラス用の設定を作成
        obj.create('roads');

    elseif strcmp(property_name, 'intersections')
        % 構造体を初期化
        intersections = struct();

        % 交差点のデータを取得
        folder = obj.simulator.folder;
        path = [pwd, '\layout\', folder, '\intersections.yaml'];
        data = yaml.loadFile(path);

        % IntersectionsMapの初期化
        IntersectionsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % 交差点を走査
        for intersection_data = data.intersections
            % セルから取り出し
            intersection_data = intersection_data{1};

            % 構造体を初期化
            intersection = struct();

            % 交差点のIDを設定
            intersection.id = intersection_data.id;

            % 交差点の制御方式を設定
            intersection.method = intersection_data.method;

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

            % IntersectionsMapにintersectionをプッシュ  
            IntersectionsMap(intersection.id) = intersection;

            % IntersectionsMapをintersectionsにプッシュ
            intersections.IntersectionsMap = IntersectionsMap;

            % intersectionsをnetworkにプッシュ
            obj.network.intersections = intersections;
        end

    elseif strcmp(property_name, 'roads')
        % 構造体を初期化
        roads = struct();

        % 道路のデータを取得
        folder = obj.simulator.folder;
        path = [pwd, '\layout\', folder, '\roads.yaml'];
        data = yaml.loadFile(path);

        % RoadsMapの初期化
        RoadsMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');

        % 道路を走査
        for road_data = data.roads
            % セルから取り出し
            road_data = road_data{1};

            % road_dataをRoadsMapに追加
            RoadsMap(road_data.id) = road_data;
        end

        % RoadsMapをroadsにプッシュ
        roads.RoadsMap = RoadsMap;

        % roadsをnetworkにプッシュ
        obj.network.roads = roads;
    elseif strcmp(property_name, 'controllers')
        % Controllersクラス用の設定を作成
        obj.controllers = struct();

        % MPCの設定
        obj.create('MPC');
    elseif strcmp(property_name, 'MPC')

        % MPCクラス用の設定を作成
        mpc = struct();

        % 設定ファイルを読み込む    
        data = yaml.loadFile([pwd, '\layout\config.yaml']);

        % 制御ホライゾン、予測ホライゾンを取得
        mpc.N_p = data.mpc.N_p;
        mpc.N_c = data.mpc.N_c;

        % mpcをcontrollersにプッシュ
        obj.controllers.MPC = mpc;

    else
        error('error: invalid property_name');
    end
end