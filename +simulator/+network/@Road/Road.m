classdef Road < utils.class.Common
    properties
        Config;
        Roads;
    end

    properties
        id;
        links;
        speed;

        vehicles;
    end

    methods
        function obj = Road(Roads)
            % Configクラスを設定
            obj.Config = Roads.get('Config');

            % Roadsクラスを設定
            obj.Roads = Roads;
        end
    end

    methods
        create(obj, property_name);
    end
end