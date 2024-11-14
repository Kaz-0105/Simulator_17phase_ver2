classdef Intersection < utils.class.Common
    properties
        Config;
        Intersections;

        Controller;
        Roads;
    end

    properties
        id;
        method;
        signal_controller;

        current_time;
        record_flags;
    end

    methods
        function obj = Intersection(Intersections, intersection_struct)
            % ConfigクラスとIntersectionクラスを設定
            obj.Config = Intersections.get('Config');
            obj.Intersections = Intersections;

            % idとメソッドを設定
            obj.id = intersection_struct.id;
            obj.method = intersection_struct.method;

            % intersection_structをセット
            obj.set('intersection_struct', intersection_struct);

            % Roadsクラスを作成
            obj.create('Roads');

            % RordOrderMapの作成
            obj.create('RoadOrderMap');

            % current_timeの初期化
            obj.create('current_time');

            % record_flagsを作成
            obj.create('record_flags');

            % queue_tableを作成
            % obj.create('queue_table');

            % delay_tableを作成
            % obj.create('delay_table');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj, phase_id, type);
    end
end