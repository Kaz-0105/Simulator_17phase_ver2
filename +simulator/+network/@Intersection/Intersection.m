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

        current_time;
    end

    methods
        function obj = Intersection(Intersections)
            % Configクラスを設定
            obj.Config = Intersections.get('Config');

            % Intersectionsクラスを設定
            obj.Intersections = Intersections;

            % current_timeの初期化
            obj.create('current_time');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj, phase_id, type);
    end
end