classdef Container < utils.class.Common
    methods
        function obj = Container()
        end

        function num_elements = count(obj)
            num_elements = int64(obj.Elements.Count);
        end

        function element = itemByKey(obj, key)
            element = obj.Elements(key);
        end

        function keys = getKeys(obj)
            keys = cell2mat(obj.Elements.keys);
        end
    end
end