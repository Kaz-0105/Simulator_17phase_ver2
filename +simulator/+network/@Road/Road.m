classdef Road < utils.class.Common
    properties
        Config;
        Timer;
        Roads;
        Intersections;
        Links;
        DataCollections;
    end

    properties
        id;
        links;
        speed;
        
        record_flags;
    end

    methods
        function obj = Road(Roads, road_struct)
            % ConfigクラスとRoadsクラスを設定
            obj.Config = Roads.get('Config');
            obj.Timer = Roads.get('Timer');
            obj.Roads = Roads;

            % idを設定
            obj.id = road_struct.id;

            % road_structを設定
            obj.set('road_struct', road_struct);

            % Links, speedを作成
            obj.create('Links');
            obj.create('speed');

            % SignalHeadsを作成
            obj.create('SignalHeads');

            % QueueCountersを作成
            obj.create('QueueCounters');

            % DelayMeasurementsを作成
            obj.create('DelayMeasurements');

            % DataCollectionMeasurementsを初期化
            obj.create('DataCollections');

            % record_flagsを作成
            obj.create('record_flags');

            % Intersectionsの初期化
            obj.Intersections = struct();
        end
    end

    methods
        create(obj, property_name);
    end
end