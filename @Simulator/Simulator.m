classdef Simulator < utils.class.Common
    properties
        Config;
        Timer;
        Network;
        Controllers;
    end

    properties
        Vissim;
    end

    properties
        ModelsMap;
    end

    properties
        seed;
        running_flag;
    end

    methods
        function obj = Simulator(Config)
            % Configクラスを設定
            obj.Config = Config;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % シミュレーションが動いているかどうかのフラグ
            obj.running_flag = false;

            % Timerクラスを作成
            obj.Timer = simulator.Timer(obj);

            % Networkクラスを作成
            obj.Network = simulator.Network(obj);

            % Controllersクラスを作成
            obj.Controllers = simulator.Controllers(obj);

            % Modelsクラスを作成
            obj.create('ModelsMap');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj);
        save(obj);
    end
end