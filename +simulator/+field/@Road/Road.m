classdef Road < utils.class.Common
    properties
        Config;
        Roads;
    end

    properties
        id;
    end

    methods
        function obj = Road(Roads)
            % Configクラスを設定
            obj.Config = Roads.get('Config');

            % Roadsクラスを設定
            obj.Roads = Roads;
        end
    end
end