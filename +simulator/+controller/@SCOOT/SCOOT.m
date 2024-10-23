classdef SCOOT < utils.class.Common
    properties
        Config;
        Controller;
        Roads;
    end

    properties
        cycle_time;
        PhaseSplitMap;
    end

    methods 
        function obj = SCOOT(Controller)
            % Configクラスを取得
            obj.Config = Controller.get('Config');

            % Controllerクラスを取得
            obj.Controller = Controller;

            % Roadsクラスを取得
            Intersection = Controller.get('Intersection');
            obj.Roads = Intersection.get('InputRoads');

            % 
        end
    end
end