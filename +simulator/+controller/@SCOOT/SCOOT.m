classdef SCOOT < utils.class.Common
    properties
        Config;
        Controller;
        Intersection;
        Roads;
    end

    properties
        delta_s;
        delta_c;
        alpha;
        cycle_time;
        num_phases;
        PhaseSplitStartMap;
    end

    properties
        skip_flag;
        cycle_start_time;
        current_time;
        current_phase_id;
    end

    methods 
        function obj = SCOOT(Controller)
            % Configクラスを取得
            obj.Config = Controller.get('Config');

            % SCOOTのパラメータを取得
            scoot = obj.Config.get('controllers').SCOOT;
            obj.delta_s = scoot.ds;
            obj.delta_c = scoot.dc;
            obj.alpha = scoot.alpha;

            % Controllerクラスを取得
            obj.Controller = Controller;

            % Intersectionクラスを取得
            obj.Intersection = Controller.get('Intersection');

            % IntersectionクラスにSCOOTクラスを設定
            obj.Intersection.set('SCOOT', obj);

            % Roadsクラスを取得
            obj.Roads = Intersection.get('InputRoads');

            % RoadクラスにSCOOTクラスを設定
            for road_id = 1: obj.Roads.count()
                Road = obj.Roads.itemByKey(road_id);
                Road.set('SCOOT', obj);
            end

            % cycle_timeの初期化
            obj.cycle_time = scoot.cycle;

            % num_phaseを作成
            obj.make('num_phases');

            % PhaseSplitMapの初期化
            obj.make('PhaseSplitStartMap');

            % cycle_start_timeの初期化
            obj.make('cycle_start_time');

            % current_phase_idの初期化
            obj.current_phase_id = 1;
        end
    end

    methods
        make(obj, property_name);
        update(obj, property_name);
        run(obj);
    end
end