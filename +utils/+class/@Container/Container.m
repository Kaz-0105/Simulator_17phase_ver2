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

        function add(obj, Element)
            obj.Elements(Element.get('id')) = Element;
        end
    end

    methods (Static)
        function values = getVissimKeys(VissimCollection)
            try
                values = VissimCollection.GetMultiAttValues('No');
            catch 
                values = VissimCollection.GetMultiAttValues('Index');
            end

            values = sort(transpose(cell2mat(values)));
            values = values(2, :);
        end
    end
end