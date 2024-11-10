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
        record_flags;
    end

    methods
        function obj = Intersection(Intersections, id)
            % ConfigクラスとIntersectionクラスを設定
            obj.Config = Intersections.get('Config');
            obj.Intersections = Intersections;

            % idを設定
            obj.id = id;

            % current_timeの初期化
            obj.create('current_time');

            % record_flagsを作成
            obj.create('record_flags');

            % queue_tableを作成
            obj.create('queue_table');

            % delay_tableを作成
            obj.create('delay_table');

            % Roadsクラスを作成
            obj.create('Roads');

            % RordOrderMapの作成
            obj.create('RoadOrderMap');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj, phase_id, type);
    end
end