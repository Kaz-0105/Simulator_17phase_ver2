classdef Controllers < utils.class.Container
    properties
        Config;
        Simulator;

        Network;
    end

    properties
        Elements;
    end

    methods
        function obj = Controllers(Simulator)
            % Configクラスを設定
            obj.Config = Simulator.get('Config');

            % Simulatorクラスを設定
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