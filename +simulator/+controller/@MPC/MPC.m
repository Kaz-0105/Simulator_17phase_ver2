classdef MPC < utils.class.Common
    properties
        Config;
        Controller;
        Roads;
    end

    properties
        RoadPrmMap;
        MLDsMap;
        MILPsMap;
    end

    properties
        dt;
        N_p;
        N_c;
    end

    methods
        function obj = MPC(Controller)
            % Configクラスを設定
            obj.Config = Controller.get('Config');

            % Controllerクラスを設定
            obj.Controller = Controller;

            % Roadsクラスを設定
            Intersection = Controller.get('Intersection');
            obj.Roads = Intersection.get('InputRoads');

            % RoadPrmMapの作成
            obj.create('RoadPrmMap');

            % タイムステップの設定
            simulator = obj.Config.get('simulator');
            obj.dt = simulator.dt;

            % ホライゾンの設定
            controllers = obj.Config.get('controllers');
            obj.N_p = controllers.MPC.N_p;
            obj.N_c = controllers.MPC.N_c;
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        validate(obj, property_name);
        run(obj);
    end
end