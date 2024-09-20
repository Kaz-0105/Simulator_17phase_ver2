classdef Config < utils.class.Common
    properties
        simulator;
        field;
        intersections;
        roads;
    end

    methods
        function obj = Config()
            % Simulatorクラス用の設定を作成
            obj.create('simulator');

            % Fieldクラス用の設定を作成
            obj.create('field');

            % Intersectionsクラス用の設定を作成
            obj.create('intersections');

            % Roadsクラス用の設定を作成
            obj.create('roads');
        end
    end

    methods
        create(obj, property_name);
    end
end