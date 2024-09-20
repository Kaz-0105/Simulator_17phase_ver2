classdef Field < utils.class.Common
    properties
        Config;
        Simulator;
        Controllers;
        Intersections;
        Roads;
    end

    methods
        function obj = Field(Simulator)
            % Configクラスを設定
            obj.Config = Simulator.get('Config');

            % Simulatorクラスを設定
            obj.Simulator = Simulator;

            % Intersectionsクラスを作成
            obj.Intersections = simulator.field.Intersections(obj);

            % Roadsクラスを作成
            obj.Roads = simulator.field.Roads(obj);

            % IntersectionクラスとRoadクラスの接続関係を定義
            obj.update('Intersections');
            obj.update('Roads');
        end
    end

    methods
        update(obj, property_name);
    end
end