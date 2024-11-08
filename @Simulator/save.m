function save(obj)
    % Simulatorクラス用の設定を取得する
    simulator = obj.Config.get('simulator');

    % フォルダが存在しない場合は作成する
    if ~exist([pwd, '/results/', simulator.folder], 'dir')
        mkdir([pwd, '/results/', simulator.folder]);
    end
    
    % performance_indicatorsがtrueのとき
    if simulator.save.performance_indicators
        % csvファイルが存在しないときはcsvファイルを作成する
        if ~exist([pwd, '/results/', simulator.folder, '/simulations.csv'], 'file')
        end
        
        % csvファイルを読み込む
        SimulatorModel = utils.class.Model(simulator.folder, 'simulation');
        InputsModel = utils.class.Model(simulator.folder, 'inputs');
        IntersectionsModel = utils.class.Model(simulator.folder, 'intersections');
        IntersectionModel = utils.class.Model(simulator.folder, 'intersection');
        MethodModel = utils.class.Model(simulator.folder, 'method');
        MpcModel = utils.class.Model(simulator.folder, 'mpc');
        ScootModel = utils.class.Model(simulator.folder, 'scoot');


    end
end