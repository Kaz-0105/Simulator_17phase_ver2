classdef Container < utils.class.Common
    properties
        Elements;
    end
    
    methods
        function obj = Container()
            obj.Elements = containers.Map('KeyType', 'double', 'ValueType', 'any');
        end

        function num_elements = count(obj)
            num_elements = double(obj.Elements.Count);
        end

        function element = itemByKey(obj, key)
            element = obj.Elements(key);
        end

        function keys = getKeys(obj)
            keys = sort(cell2mat(obj.Elements.keys));
        end

        function add(obj, Element, key)
            % 引数を初期化
            if nargin == 2
                obj.Elements(Element.get('id')) = Element;
            elseif nargin == 3
                obj.Elements(key) = Element;
            end 
        end
    end

    methods (Static)
        function values = getVissimKeys(VissimContainer)
            try
                values = VissimContainer.GetMultiAttValues('No');
            catch 
                values = VissimContainer.GetMultiAttValues('Index');
            end

            values = sort(transpose(cell2mat(values)));
            values = values(2, :);
        end
    end
end