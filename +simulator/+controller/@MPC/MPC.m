classdef MPC < utils.class.Common
    properties
        Config;
        Controller;
        Roads;
    end

    properties
        RoadParameterMap;
        MLDsMap;
        MILPsMap;
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

            % RoadParameterMapの作成
            obj.create('RoadParameterMap');

        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj);
    end
end