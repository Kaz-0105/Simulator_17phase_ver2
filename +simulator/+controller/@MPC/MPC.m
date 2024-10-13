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

            % dtの設定
            simulator = obj.Config.get('simulator');
            obj.dt = simulator.dt;

            % N_pの設定
            mpc = obj.Config.get('mpc');
            obj.N_p = mpc.N_p;
            obj.N_c = mpc.N_c;
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        validate(obj, property_name);
        run(obj);
    end
end