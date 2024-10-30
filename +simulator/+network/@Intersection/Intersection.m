classdef Intersection < utils.class.Common
    properties
        Config;
        Intersections;

        Controller;
        InputRoads;
        OutputRoads;
    end

    properties
        id;
        method;
        signal_controller;
    end

    methods
        function obj = Intersection(Intersections)
            % Configクラスを設定
            obj.Config = Intersections.get('Config');

            % Intersectionsクラスを設定
            obj.Intersections = Intersections;
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj, phase_id, type);
    end
end