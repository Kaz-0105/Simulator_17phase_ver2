classdef Network < utils.class.Common
    properties
        Config;
        Simulator;
        Controllers;
        Intersections;
        Roads;
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

            % Intersectionsクラスを作成
            obj.Intersections = simulator.network.Intersections(obj);

            % Roadsクラスを作成
            obj.Roads = simulator.network.Roads(obj);

            % IntersectionクラスとRoadクラスの接続関係を定義
            obj.update('Intersections');
            obj.update('Roads');

            % current_timeの初期化
            obj.current_time = obj.Simulator.get('current_time');
        end
    end

    methods
        update(obj, property_name);
    end
end