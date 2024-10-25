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
        beta;
        cycle_time;
        num_phases;
        PhaseSplitStartMap;
    end

    properties
        skip_flag;
        objective;
        cycle_start_time;
        current_time;
        current_phase_id;
    end

    properties
        PhaseInflowRateMap;
        PhaseOutflowRateMap;
        PhaseSaturationMap;
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
            obj.Roads = obj.Intersection.get('InputRoads');

            % RoadクラスにSCOOTクラスを設定
            for road_id = 1: obj.Roads.count()
                Road = obj.Roads.itemByKey(road_id);
                Road.set('SCOOT', obj);
            end

            % cycle_timeの初期化
            obj.cycle_time = scoot.cycle;

            % num_phaseを作成
            obj.create('num_phases');

            % cycle_start_timeの初期化
            obj.create('cycle_start_time');

            % PhaseSplitMapの初期化
            obj.create('PhaseSplitStartMap');

            % current_phase_idの初期化
            obj.current_phase_id = 1;

            % PhaseSaturationRateMap、PhaseInflowRateMap、PhaseOutflowRateMapの初期化
            obj.create('PhaseSaturationMap');
            obj.create('PhaseInflowRateMap');
            obj.create('PhaseOutflowRateMap');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
        run(obj);
    end
end