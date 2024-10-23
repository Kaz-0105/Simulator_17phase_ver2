classdef SCOOT < utils.class.Common
    properties
        Config;
        Controller;
        Roads;
    end

    properties
        delta_s;
        delta_c;
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

            % Controllerクラスを取得
            obj.Controller = Controller;

            % Roadsクラスを取得
            Intersection = Controller.get('Intersection');
            obj.Roads = Intersection.get('InputRoads');

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