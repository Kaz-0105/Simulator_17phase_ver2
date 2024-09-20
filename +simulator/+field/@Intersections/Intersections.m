classdef Intersections < utils.class.Container
    properties
        Config;
        Field;
        Roads;
    end

    properties
        Elements;
    end

    methods
        function obj = Intersections(Field)
            % Configクラスを設定
            obj.Config = Field.get('Config');

            % Fieldクラスを設定
            obj.Field = Field;

            % 要素クラスを作成
            obj.create('Elements');
        end
    end

    methods
        create(obj, property_name);
    end
end