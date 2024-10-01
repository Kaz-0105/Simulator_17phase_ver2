classdef Controller < utils.class.Common
    properties
        Config;
        Controllers;

        Intersection;
    end

    properties
        id;
    end

    methods 
        function obj = Controller(Controllers)
            % Configクラスを設定
            obj.Config = Controllers.get('Config');

            % Controllersクラスを設定
            obj.Controllers = Controllers;

            % idを設定
            obj.id = Controllers.count() + 1;
        end
    end

    methods
        create(obj, property_name);
        update(obj, property_name);
    end
end