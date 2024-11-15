classdef Mpc < utils.class.Common
    properties
        Config;
        Controller;
        Intersection;
        Roads;
    end

    properties
        RoadPrmMap;
        MLDsMap;
        MILPsMap;
        VariableListMap;
        RoadDeltaTMap;
    end

    properties
        dt;
        N_p;
        N_c;

        pos_vehs;
        
        u_length;
        z_length;
        delta_length;
        v_length;
    end

    methods
        function obj = Mpc(Controller)
            % Configクラスを設定
            obj.Config = Controller.get('Config');

            % Controllerクラスを設定
            obj.Controller = Controller;

            % Intersectionクラスを設定
            obj.Intersection = Controller.get('Intersection');

            % IntersectionクラスにMpcクラスを設定
            obj.Intersection.set('Mpc', obj);

            % Roadsクラスを設定
            obj.Roads = obj.Intersection.get('Roads');
            
            % RoadクラスにMpcクラスを設定
            for road_id = 1: obj.Roads.input.count()
                Road = obj.Roads.itemByKey(road_id);
                Road.set('Mpc', obj);
            end

            % u_lengthの設定
            obj.u_length = obj.Roads.count() * (obj.Roads.count() - 1);

            % RoadPrmMapの作成
            obj.create('RoadPrmMap');

            % ホライゾンの設定
            controllers = obj.Config.get('controllers');
            obj.dt = controllers.Mpc.dt;
            obj.N_p = controllers.Mpc.N_p;
            obj.N_c = controllers.Mpc.N_c;
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        validate(obj, property_name);
        run(obj);
    end
end