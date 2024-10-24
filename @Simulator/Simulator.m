classdef Simulator < utils.class.Common
    properties
        Config;
        Network;
        Controllers;
    end

    properties
        Vissim;
    end

    properties
        dt;
        time;
        seed;

        break_point;
        current_time;
    end

    methods
        function obj = Simulator(Config)
            % Configクラスを設定
            obj.Config = Config;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % ステップ時間とシミュレーション時間を設定
            obj.create('dt');
            obj.create('time');

            % ブレークポイントの初期化
            obj.break_point = 0;

            % 現在の時間の初期化
            obj.current_time = 0;

            % Networkクラスを作成
            obj.Network = simulator.Network(obj);

            % Controllersクラスを作成
            obj.Controllers = simulator.Controllers(obj);
        end
    end

    methods
        create(obj, property_name);
        run(obj);
    end
end