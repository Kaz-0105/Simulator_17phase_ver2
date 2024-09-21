classdef Simulator < utils.class.Common
    properties
        Config;
        Network;
        Controllers;
    end

    properties
        Vissim;
    end

    methods
        function obj = Simulator(Config)
            % Configクラスを設定
            obj.Config = Config;

            % Vissimと接続（COMオブジェクトの取得（Vissim））
            obj.create('Vissim');

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