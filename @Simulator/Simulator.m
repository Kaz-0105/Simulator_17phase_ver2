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
        total_time;
        seed;

        eval_interval;
        
        running_flag;

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
            obj.create('total_time');

            % 評価指標の測定間隔を設定
            obj.create('eval_interval');

            % シミュレーションが動いているかどうかのフラグ
            obj.running_flag = false;

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
        update(obj, property_name);
        run(obj);
        save(obj);
    end
end