classdef Timer < utils.class.Common
    properties
        Config;
        Simulator;
    end

    properties
        current_time;
        time_step;
        evaluation_time_step;
        finish_time;
        
        evaluation_flag;
        finish_flag;
    end

    methods
        function obj = Timer(Simulator)
            % ConfigクラスとSimulatorクラスを取得
            obj.Config = Simulator.get('Config');
            obj.Simulator = Simulator;

            % current_timeを初期化
            obj.current_time = 0;

            % time_stepを取得
            obj.create('time_step');

            % finish_timeを取得
            obj.create('finish_time');

            % evaluation_intervalを取得
            obj.create('evaluation_interval');

            % evaluation_flagを初期化
            obj.evaluation_flag = false;

            % finish_flagを初期化
            obj.finish_flag = false;
        end
    end

    methods
        create(obj, property_name);
        run(obj, seconds);
    end
end