classdef Controllers < utils.class.Container
    properties
        Config;
        Timer;
        Simulator;

        Network;
    end

    methods
        function obj = Controllers(Simulator)
            % Config、Timer、Simulatorクラスを取得
            obj.Config = Simulator.get('Config');
            obj.Timer = Simulator.get('Timer');
            obj.Simulator = Simulator;

            % Networkクラスを作成
            obj.Network = obj.Simulator.get('Network');
            obj.Network.set('Controllers', obj);

            % 要素クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
        run(obj);
    end
end