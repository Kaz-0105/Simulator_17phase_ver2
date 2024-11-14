classdef Roads < utils.class.Container
    properties
        Config;
    end

    methods
        function obj = Roads(UpperClass)
            % typeによって分岐
            if isa(UpperClass, 'simulator.Network')
                % Networkクラスを設定
                obj.set('Network', UpperClass);
                obj.Config = obj.Network.get('Config');

                % 要素クラスを作成
                obj.create('Elements');
                
            elseif isa(UpperClass, 'simulator.network.Intersection')
                % Intersectionsクラスを設定
                obj.set('Intersection', UpperClass);
                obj.Config = obj.Intersection.get('Config');

            else
                error('error: invalid argument');
            end
        end
    end

    methods
        create(obj, property_name, type);
        update(obj, property_name);
        delete(obj, property_name);
    end
end