classdef Roads < utils.class.Container
    properties
        Config;
    end

    properties
        Elements;
    end

    methods
        function obj = Roads(Field_or_Intersections)
            % Configクラスを設定
            obj.Config = Field_or_Intersections.get('Config');

            % typeによって分岐
            if isa(Field_or_Intersections, 'simulator.field.Field')
                % プロパティにFieldクラスを追加
                prop = addprop(obj, 'Field');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Fieldクラスを設定
                obj.Field = Field_or_Intersections;

                % 要素クラスを作成
                obj.create('Elements', 1);
            elseif isa(Field_or_Intersections, 'simulator.field.Intersections')
                % プロパティにIntersectionsクラスを追加
                prop = addprop(obj, 'Intersections');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Intersectionsクラスを設定
                obj.Intersections = Field_or_Intersections;

                % 要素クラスを作成
                obj.create('Elements', 2);
            else
                error('error: invalid argument');
            end
        end
    end

    methods
        create(obj, property_name, type);
    end
end