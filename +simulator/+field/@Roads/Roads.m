classdef Roads < utils.class.Container
    properties
        Config;
    end

    properties
        Elements;
    end

    methods
        function obj = Roads(Field_or_Intersection, type)
            % Configクラスを設定
            obj.Config = Field_or_Intersection.get('Config');

            % typeによって分岐
            if isa(Field_or_Intersection, 'simulator.Field')
                % プロパティにFieldクラスを追加
                prop = addprop(obj, 'Field');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Fieldクラスを設定
                obj.Field = Field_or_Intersection;

                % プロパティにIntersectionsクラスを追加
                prop = addprop(obj, 'Intersections');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Intersectionsクラスを設定
                obj.Intersections = obj.Field.get('Intersections');
                obj.Intersections.set('Roads', obj);

                % 要素クラスを作成
                obj.create('Elements', 'Field');
            elseif isa(Field_or_Intersection, 'simulator.field.Intersection')
                % プロパティにIntersectionsクラスを追加
                prop = addprop(obj, 'Intersection');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % Intersectionsクラスを設定
                obj.Intersection = Field_or_Intersection;

                % プロパティにtypeを追加
                prop = addprop(obj, 'type');
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';

                % typeを設定
                obj.type = type;

                % 要素クラスを作成
                obj.create('Elements', 'Intersection');
            else
                error('error: invalid argument');
            end
        end
    end

    methods
        create(obj, property_name, type);
    end
end