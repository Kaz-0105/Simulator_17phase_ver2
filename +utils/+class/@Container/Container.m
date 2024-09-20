classdef Container < utils.class.Common & dynamicprops
    methods
        function obj = Container()
        end

        function num_elements = count(obj)
            num_elements = obj.Elements.Count;
        end

        function element = itemByKey(obj, key)
            element = obj.Elements(key);
        end
    end
end