classdef Common < handle & dynamicprops
    properties
    end

    methods
        function obj = Common()
        end

        function value = get(obj, property_name)
            value = obj.(property_name);
        end

        function set(obj, property_name, value)

            if ~isprop(obj, property_name)
                prop = addprop(obj, property_name);
                prop.SetAccess = 'public';
                prop.GetAccess = 'public';
            end

            obj.(property_name) = value;
        end
    end
end