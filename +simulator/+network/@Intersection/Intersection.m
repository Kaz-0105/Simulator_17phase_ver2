classdef Intersection < utils.class.Common
    properties
        Config;
        Timer;
        Intersections;
        Controller;
        Roads;
    end

    properties
        PhaseSignalGroupsMap;
    end

    properties
        id;
        record_flags;
    end

    methods
        function obj = Intersection(Intersections, intersection_struct)
            % ConfigクラスとTimerクラスとIntersectionsクラスを設定
            obj.Config = Intersections.get('Config');
            obj.Timer = Intersections.get('Timer');
            obj.Intersections = Intersections;

            % idとメソッドを設定
            obj.id = intersection_struct.id;
            obj.set('method' ,intersection_struct.method);

            % intersection_structをセット
            obj.set('intersection_struct', intersection_struct);

            % Roadsクラスを作成
            obj.create('Roads');

            % RordOrderMapの作成
            obj.create('RoadOrderMap');

            % record_flagsを作成
            obj.create('record_flags');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj, phase_id, type);
    end
end