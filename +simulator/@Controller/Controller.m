classdef Controller < utils.class.Common
    properties
        Config;
        Controllers;

        Intersection;
    end

    properties
        id;
        current_time;
    end

    methods 
        function obj = Controller(Controllers)
            % Configクラスを設定
            obj.Config = Controllers.get('Config');

            % Controllersクラスを設定
            obj.Controllers = Controllers;

            % idを設定
            obj.id = Controllers.count() + 1;

            % current_timeの初期化
            obj.create('current_time');
        end
    end

    methods
        create(obj, property_name);
        run(obj);
    end
end