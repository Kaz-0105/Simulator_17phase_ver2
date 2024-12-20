classdef Road < utils.class.Common
    properties
        Config;
        Roads;
    end

    properties
        id;
        links;
        speed;

        current_time;
        record_flags;
    end

    methods
        function obj = Road(Roads)
            % Configクラスを設定
            obj.Config = Roads.get('Config');

            % Roadsクラスを設定
            obj.Roads = Roads;

            % current_timeの初期化
            obj.create('current_time');

            % record_flagsを作成
            obj.create('record_flags');
        end
    end

    methods
        create(obj, property_name);
    end
end