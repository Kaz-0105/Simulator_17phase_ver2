classdef Intersection < utils.class.Common
    properties
        Config;
        Intersections;
        InputRoads;
        OutputRoads;
    end

    properties
        id;
    end

    methods
        function obj = Intersection(Intersections)
            % Configクラスを設定
            obj.Config = Intersections.get('Config');

            % Intersectionsクラスを設定
            obj.Intersections = Intersections;
        end
    end

    methods
        create(obj, property_name);
    end
end