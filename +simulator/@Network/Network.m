classdef Network < utils.class.Common
    properties
        Config;
        Simulator;
        Controllers;
        Links;
        SignalHeads;
        QueueCounters;
        DelayMeasurements;
        VehicleInputs;
        VehicleRoutingDecisions;
        DataCollectionMeasurements;
        Roads;
        Intersections;
    end

    properties
        Vissim;
    end

    properties
        record_flags;
        current_time;
    end

    methods
        function obj = Network(Simulator)
            % Configクラスを設定
            obj.Config = Simulator.get('Config');

            % Simulatorクラスを設定
            obj.Simulator = Simulator;

            % VissimのCOMオブジェクトを設定
            obj.create('Vissim');

            % 評価指標の測定の有無のフラグを設定
            obj.create('record_flags');

            % Linksクラスを作成
            obj.Links = simulator.network.Links(obj);

            % Roadsクラスを作成
            obj.Roads = simulator.network.Roads(obj);

            % Intersectionsクラスを作成
            obj.Intersections = simulator.network.Intersections(obj);

            % SignalHeadsクラスを作成
            obj.SignalHeads = simulator.network.SignalHeads(obj);

            % QueueCountersクラスを作成
            obj.QueueCounters = simulator.network.QueueCounters(obj);

            % DelayMeasurementsクラスを作成
            obj.DelayMeasurements = simulator.network.DelayMeasurements(obj);

            % VehicleRoutingDecisionsクラスを作成
            obj.VehicleRoutingDecisions = simulator.network.VehicleRoutingDecisions(obj);

            % VehicleInputsクラスを作成
            obj.VehicleInputs = simulator.network.VehicleInputs(obj);

            % DataCollectionMeasurementsクラスを作成
            obj.DataCollectionMeasurements = simulator.network.DataCollectionMeasurements(obj);
            
            % current_timeの初期化
            obj.current_time = obj.Simulator.get('current_time');
        end
    end

    methods
        update(obj, property_name);
    end
end