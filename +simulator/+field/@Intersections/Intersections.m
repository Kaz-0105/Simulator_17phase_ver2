classdef Intersections < utils.class.Container
    properties
        Config;
    end

    properties
        Elements;
    end

    methods
        function obj = Intersections(Field_or_Roads)
            % Configクラスを設定
            obj.Config = Field_or_Roads.get('Config');

            % typeによって分岐
            if isa(Field_or_Roads, 'simulator.Field')
                % プロパティにFieldクラスを追加
                prop = addprop(obj, 'Field');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Fieldクラスを設定
                obj.Field = Field_or_Roads;

                % 要素クラスを作成
                obj.create('Elements', 1);

            elseif isa(Field_or_Roads, 'simulator.field.Roads')
                % プロパティにRoadsクラスを追加
                prop = addprop(obj, 'Roads');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Roadsクラスを設定
                obj.Roads = Field_or_Roads;

                % 要素クラスを作成
                obj.create('Elements', 2);

            end
        end
    end

    methods
        create(obj, property_name, type);
    end
end