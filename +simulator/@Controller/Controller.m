classdef Controller < utils.class.Common
    properties
        Config;
        Timer;
        Controllers;

        Intersection;
    end

    properties
        id;
    end

    methods 
        function obj = Controller(Controllers, id)
            % Configクラス、Timerクラス、Controllersクラスを取得
            obj.Config = Controllers.get('Config');
            obj.Timer = Controllers.get('Timer');
            obj.Controllers = Controllers;

            % idを設定
            obj.id = id;
        end
    end

    methods
        create(obj, property_name);
        run(obj);
    end
end