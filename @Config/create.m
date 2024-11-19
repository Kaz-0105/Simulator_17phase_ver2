function create(obj, property_name)
    if strcmp(property_name, 'simulator')
        % 構造体を初期化
        obj.simulator = struct();

        % 設定ファイルを読み込む
        data = yaml.loadFile([pwd, '\layout\config.yaml']);

        % シミュレーションに使用するフォルダを設定
        obj.simulator.folder = char(data.simulator.folder);

        % ステップ時間を設定
        obj.simulator.time_step = data.simulator.time_step;

        % シミュレーション時間を設定
        obj.simulator.finish_time = data.simulator.finish_time;

        % Vissimのシード値を設定
        obj.simulator.seed = data.simulator.seed;

        % VissimのシミュレーションのモードをQuickModeにするか設定
        obj.simulator.quick_mode = logical(data.simulator.quick_mode);

        % evaluation構造体を初期化
        evaluation = struct();

        % データの測定間隔を設定
        evaluation.time_step = data.simulator.evaluation.time_step;

        % queue_lengthの測定の有無を設定
        if strcmp(char(data.simulator.evaluation.queue_length), 'on')
            evaluation.queue_length = true;
        else
            evaluation.queue_length = false;
        end

        % delay_timeの測定の有無を設定
        if strcmp(char(data.simulator.evaluation.delay_time), 'on')
            evaluation.delay_time = true;
        else
            evaluation.delay_time = false;
        end

        % evaluationをsimulatorにプッシュ
        obj.simulator.evaluation = evaluation;

        % save構造体を初期化
        save = struct();

        % performance_indicatorsの保存の有無を設定
        if strcmp(char(data.simulator.save.performance_indicators), 'on')
            save.performance_indicators = true;
        else
            save.performance_indicators = false;
        end
        
        % saveをsimulatorにプッシュ
        obj.simulator.save = save;

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

        % Vissimにデータの更新間隔を設定

        % DataCollectionについての設定
        obj.Vissim.Evaluation.set('AttValue', 'DataCollCollectData', true);
        obj.Vissim.Evaluation.set('AttValue', 'DataCollInterval', obj.simulator.time_step);
        obj.Vissim.Evaluation.set('AttValue', 'DataCollFromTime', 0);
        obj.Vissim.Evaluation.set('AttValue', 'DataCollToTime', obj.simulator.finish_time);

        % DelayTimeについての設定
        obj.Vissim.Evaluation.set('AttValue', 'DelaysCollectData', obj.simulator.evaluation.delay_time);
        obj.Vissim.Evaluation.set('AttValue', 'DelaysInterval', obj.simulator.evaluation.time_step);
        obj.Vissim.Evaluation.set('AttValue', 'DelaysFromTime', 0);
        obj.Vissim.Evaluation.set('AttValue', 'DelaysToTime', obj.simulator.finish_time);

        % QueueLengthについての設定
        obj.Vissim.Evaluation.set('AttValue', 'QueuesCollectData', obj.simulator.evaluation.queue_length);
        obj.Vissim.Evaluation.set('AttValue', 'QueuesInterval', obj.simulator.evaluation.time_step);
        obj.Vissim.Evaluation.set('AttValue', 'QueuesFromTime', 0);
        obj.Vissim.Evaluation.set('AttValue', 'QueuesToTime', obj.simulator.finish_time);

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
        IntersectionsMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

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
        RoadsMap = containers.Map('KeyType', 'double', 'ValueType', 'any');

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
    elseif strcmp(property_name, 'parameters')
        % パラメータのデータを取得
        folder = obj.simulator.folder;
        path = [pwd, '\layout\', folder, '\parameters.yaml'];
        data = yaml.loadFile(path);

        % 道路パラメータを取得
        roads_data = data.parameters.roads;

        % roads構造体を取得
        roads = obj.network.roads;

        % RoadsMapを取得
        RoadsMap = roads.RoadsMap;

        %　road_dataを走査
        for road_data = roads_data
            % セルから取り出し
            road_data = road_data{1};

            % RoadsMapからroad構造体を取得
            road = RoadsMap(road_data.id);

            % road_dataにspeedを追加
            road.speed = road_data.speed;

            % road_dataにinflowsを追加（あれば）
            if isfield(road_data, 'inflows')
                road.inflows = road_data.inflows;
            end

            % road構造体をRoadsMapにプッシュ
            RoadsMap(road_data.id) = road;
        end

        % 交差点パラメータを取得
        intersections_data = data.parameters.intersections;

        % intersections構造体を取得
        intersections = obj.network.intersections;

        % IntersectionsMapを取得
        IntersectionsMap = intersections.IntersectionsMap;

        % intersections_dataを走査
        for intersection_data = intersections_data
            % セルから取り出し  
            intersection_data = intersection_data{1};

            % IntersectionsMapからintersection構造体を取得
            intersection = IntersectionsMap(intersection_data.id);

            % input_roadsを初期化
            input_roads = [];

            % road構造体を走査
            for road = intersection.input_roads
                % road_dataを取得
                road_data = intersection_data.roads{road.id};

                % rel_flowsを初期化
                rel_flows = [];

                % rel_flow_dataを走査
                for rel_flow_data = road_data.rel_flows
                    % セルから取り出してrel_flowsにプッシュ
                    rel_flows = [rel_flows, rel_flow_data{1}];
                end

                % roadにrel_flowsをプッシュ
                road.rel_flows = rel_flows;

                % roadをinput_roadsにプッシュ
                input_roads = [input_roads, road];
            end

            % input_roadsをintersectionにプッシュ
            intersection.input_roads = input_roads;

            % intersection構造体をIntersectionsMapにプッシュ
            IntersectionsMap(intersection.id) = intersection;
        end


    elseif strcmp(property_name, 'controllers')
        % Controllersクラス用の設定を作成
        obj.controllers = struct();

        % Mpcの設定
        obj.create('Mpc');

        % Scootの設定
        obj.create('Scoot');
    elseif strcmp(property_name, 'Mpc')
        % Mpcクラス用の設定を作成
        mpc = struct();

        % 設定ファイルを読み込む    
        data = yaml.loadFile([pwd, '\layout\config.yaml']);

        % タイムステップを取得
        mpc.dt = data.mpc.dt;

        % 制御ホライゾン、予測ホライゾンを取得
        mpc.N_p = data.mpc.N_p;
        mpc.N_c = data.mpc.N_c;

        % D_o（目的関数の見る範囲）を取得
        mpc.D_o = data.mpc.D_o;

        % mpcをcontrollersにプッシュ
        obj.controllers.Mpc = mpc;

    elseif strcmp(property_name, 'Scoot')
        % Scootクラス用の設定を作成
        scoot = struct();

        % 設定ファイルを読み込む
        data = yaml.loadFile([pwd, '\layout\config.yaml']);

        % スプリットとサイクルの変動幅を取得
        scoot.split_change_width = data.scoot.split_change_width;

        % スタートの周期を取得
        scoot.initial_cycle_time = data.scoot.initial_cycle_time;

        % スプリットの最小時間を取得
        scoot.min_split_time = data.scoot.min_split_time;

        % emergency_thresholdを取得
        scoot.emergency_threshold = data.scoot.emergency_threshold;
        
        % 指数移動平均の係数を取得
        scoot.alpha = data.scoot.alpha;
        scoot.beta = data.scoot.beta;

        % 黄色時間と赤時間を取得
        scoot.yellow_time = data.scoot.yellow_time;
        scoot.red_time = data.scoot.red_time;

        % Scootの設定をcontrollersにプッシュ
        obj.controllers.scoot = scoot;
    else
        error('error: invalid property_name');
    end
end