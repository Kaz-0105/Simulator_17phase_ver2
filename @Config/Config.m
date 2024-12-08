classdef Config < utils.class.Common
    properties
        Vissim;
    end

    properties
        simulator;
        network;
        controllers;
    end

    methods
        function obj = Config()
            % Simulatorクラス用の設定を作成
            obj.create('simulator');

            % VissimのCOMオブジェクトを作成
            obj.create('Vissim');

            % Networkクラス用の設定を作成
            obj.create('network');

            % Networkクラス用の設定にパラメータを追加
            obj.create('parameters');

            % Controllersクラス用の設定を作成
            obj.create('controllers');
        end
    end

    methods
        create(obj, property_name);
    end

    methods
        function setInputsForMscs(obj, inputs_id)
            % csvファイルから流入量を取得
            inputs = readtable([pwd, '/results/', obj.simulator.folder, '/inputs.csv']);
            inputs = inputs(inputs.id == inputs_id, :);
            
            % road構造体を更新
            intersection_struct = obj.network.intersections.IntersectionsMap(1);
            RoadsMap = obj.network.roads.RoadsMap;
            for input_road = intersection_struct.input_roads
                order = input_road.id;
                road_id = input_road.road_id;
                road_struct = RoadsMap(road_id);
                road_struct.inflows = inputs.("input" + string(order));
                RoadsMap(road_id) = road_struct;
            end
        end

        function setRelFlowsForMscs(obj, rel_flows_id)
            % csvファイルから旋回率を取得
            rel_flows = readtable([pwd, '/results/', obj.simulator.folder, '/rel_flows.csv']);
            rel_flows = rel_flows(rel_flows.id == rel_flows_id, :);

            % road構造体を更新
            intersection_struct = obj.network.intersections.IntersectionsMap(1);
            input_roads = intersection_struct.input_roads;
            for input_road = input_roads
                rel_flows_struct = input_road.rel_flows;
                for rel_flow = rel_flows_struct
                    rel_flow.value = rel_flows.("rel_flow" + string(rel_flow.id));
                    rel_flows_struct(rel_flow.id) = rel_flow;
                end
                input_road.rel_flows = rel_flows_struct;
                input_roads(input_road.id) = input_road;
            end
            intersection_struct.input_roads = input_roads;
            obj.network.intersections.IntersectionsMap(1) = intersection_struct;
        end

        function setFinishTime(obj, finish_time)
            obj.simulator.finish_time = finish_time;

            obj.Vissim.Evaluation.set('AttValue', 'DataCollToTime', obj.simulator.finish_time);
            obj.Vissim.Evaluation.set('AttValue', 'DelaysToTime', obj.simulator.finish_time);
            obj.Vissim.Evaluation.set('AttValue', 'QueuesToTime', obj.simulator.finish_time);
        end
    end
end