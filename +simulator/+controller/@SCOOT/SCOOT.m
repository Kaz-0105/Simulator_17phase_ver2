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
        objectives;

        current_time;

        current_phase_id;
        current_split_start;
        current_cycle_start;
        
        next_phase_id;
        next_split_start;
        next_cycle_start;
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
            obj.alpha = scoot.alpha;
            obj.beta = scoot.beta;

            % Controllerクラスを取得
            obj.Controller = Controller;

            % Intersectionクラスを取得
            obj.Intersection = Controller.get('Intersection');

            % IntersectionクラスにSCOOTクラスを設定
            obj.Intersection.set('SCOOT', obj);

            % IntersectionクラスにPhaseSignalGroupsMapを作成
            obj.create('PhaseSignalGroupsMap');

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

            % current_timeの初期化
            obj.create('current_time');

            % current_phase_idとnext_phase_idの初期化
            obj.current_phase_id = 1;
            obj.next_phase_id = 2;

            % current_cycle_start、next_cycle_startの初期化
            obj.current_cycle_start = obj.current_time;
            obj.next_cycle_start = obj.current_time + obj.cycle_time;

            % PhaseSplitStartMapの初期化
            obj.create('PhaseSplitStartMap');

            % current_split_start, next_split_startの初期化
            obj.current_split_start = obj.current_time;
            obj.next_split_start = obj.PhaseSplitStartMap(obj.next_phase_id);

            % PhaseSaturationRateMap、PhaseInflowRateMap、PhaseOutflowRateMapの初期化
            obj.create('PhaseSaturationMap');
            obj.create('PhaseInflowRateMap');
            obj.create('PhaseOutflowRateMap');
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name, varargin);
        run(obj);
    end
end