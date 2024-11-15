classdef Scoot < utils.class.Common
    properties
        Config;
        Timer;
        Controller;
        Intersection;
        Roads;
    end

    properties
        split_change_width;
        cycle_change_width;
        min_cycle;
        alpha;
        beta;
        yellow_time;
        red_time;

        cycle_time;
        num_phases;
    end

    properties
        skip_flag;
        objectives;

        phase_ids;

        current_split_start;
        next_split_start;
        split_adjusted_flag;

        current_cycle_start;
        next_cycle_start;
    end

    properties
        PhaseInflowRateMap;
        PhaseOutflowRateMap;
        PhaseSaturationMap;
        PhaseSplitStartMap;
    end

    methods 
        function obj = Scoot(Controller)
            % Config、Timerクラス、Controllerクラスを取得
            obj.Config = Controller.get('Config');
            obj.Timer = Controller.get('Timer');
            obj.Controller = Controller;

            % Intersectionクラス、Roadsクラスを取得
            obj.Intersection = Controller.get('Intersection');
            obj.Roads = obj.Intersection.get('Roads').input;

            % scootのパラメータを取得
            scoot = obj.Config.get('controllers').scoot;
            obj.split_change_width = scoot.split_change_width;
            obj.min_cycle = scoot.min_cycle;
            obj.alpha = scoot.alpha;
            obj.beta = scoot.beta;
            obj.cycle_time = scoot.initial_cycle;
            obj.yellow_time = scoot.yellow_time;
            obj.red_time = scoot.red_time;

            % num_phaseを作成
            obj.create('num_phases');
            obj.cycle_change_width = obj.num_phases;
            obj.phase_ids = 1: obj.num_phases;

            % PhaseSplitStartMapの初期化
            obj.create('PhaseSplitStartMap');

            % current_split_start, next_split_startの初期化
            obj.current_split_start = obj.Timer.get('current_time');
            obj.next_split_start = obj.PhaseSplitStartMap(obj.next_phase_id);
            obj.split_adjusted_flag = false;

            % current_cycle_start、next_cycle_startの初期化
            obj.current_cycle_start = obj.Timer.get('current_time');
            obj.next_cycle_start = obj.current_time + obj.cycle_time;

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