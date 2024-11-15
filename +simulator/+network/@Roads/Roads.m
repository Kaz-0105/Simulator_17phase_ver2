classdef Roads < utils.class.Container
    properties
        Config;
        Timer;
    end

    methods
        function obj = Roads(UpperClass)
            % typeによって分岐
            if isa(UpperClass, 'simulator.Network')
                % ConfigクラスとTimerクラスとNetworkクラスを設定
                obj.set('Network', UpperClass);
                obj.Config = obj.Network.get('Config');
                obj.Timer = obj.Network.get('Timer');

                % 要素クラスを作成
                obj.create('Elements');
                
            elseif isa(UpperClass, 'simulator.network.Intersection')
                % ConfigクラスとTimerクラスとIntersectionクラスを設定
                obj.set('Intersection', UpperClass);
                obj.Config = obj.Intersection.get('Config');
                obj.Timer = obj.Intersection.get('Timer');

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